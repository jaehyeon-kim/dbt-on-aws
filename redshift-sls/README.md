# dbt on Amazon Redshift Serverless

This folder builds the IMDb data models on Amazon Redshift Serverless. The dbt models are the same seven staging, five intermediate and three marts models as in the other four folders, so what this folder shows is the Redshift path: the adapter, the connection and the storage.

## What differs from the other folders

- Adapter: `dbt-redshift`, with the `dbt_redshift_sls` project.
- Connection: the Redshift Serverless workgroup sits in private subnets. The developer machine reaches it through a SoftEther VPN server that the same Terraform creates in a public subnet, so a VPN connection must be up before any dbt command. The VPN and Redshift admin credentials are generated in Terraform and stored in AWS Secrets Manager, see `infra/secrets.tf`.
- Storage: native Redshift tables in the `imdb` and `imdb_analytics` schemas. This is the only folder with no Glue Data Catalog and no Parquet on S3. The source tables are loaded with `COPY` from S3 by `setup-redshift.sql`, not by a Glue crawler and not by `dbt_external_tables`.
- dbt packages: `dbt-labs/codegen` 0.8.0 and `dbt-labs/dbt_utils` 0.9.2. `codegen` is used here only.

## Stack

- Terraform with the AWS provider `>= 3.72`. It creates a VPC across three availability zones, a SoftEther VPN autoscaling group, an S3 bucket, a Secrets Manager secret, and a Redshift Serverless namespace and workgroup with a base capacity of 128.
- dbt with the `dbt-redshift` adapter.
- `axel` is needed by `upload-data.sh`, which downloads the IMDb TSV files.

## How to run

These commands create real AWS resources and they cost money while they exist. Redshift Serverless bills for compute and the VPN instance runs continuously, so destroy the stack when you have finished. Run the commands from this folder.

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
```

Download the IMDb data and copy it to S3. Edit the `s3_bucket` value in `upload-data.sh` first: unlike the other four folders, this script has a `<s3-bucket-name>` placeholder rather than reading the Terraform output, because the bucket output here is named `data_bucket_name` and is a map.

```bash
./upload-data.sh
```

Connect to the VPN server, then run `setup-redshift.sql` against the workgroup with a SQL client. Replace the `<password>` and `<s3-bucket-name>` placeholders in the file first. It creates the two schemas, creates the `dbt` user and group, and loads the seven source tables with `COPY`.

Install dbt and write the profile. `dbt init` asks for the project name, the adapter and the workgroup endpoint, and writes `~/.dbt/profiles.yml`. There is no `set-profile.sh` in this folder.

```bash
pip install dbt-core dbt-redshift
dbt init
```

Run the project. The VPN connection has to stay up throughout.

```bash
cd dbt_redshift_sls
dbt deps
dbt debug
dbt run
dbt test
```

Tear everything down.

```bash
terraform -chdir=infra destroy
```

## Posts

- [Data Build Tool (dbt) for Effective Data Transformation on AWS – Part 1 Redshift](https://jaehyeon.me/blog/2022-09-28-dbt-on-aws-part-1-redshift/)

## Back to the repository

[dbt-on-aws](../)
