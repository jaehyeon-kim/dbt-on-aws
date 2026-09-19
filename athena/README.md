# dbt on Amazon Athena

This folder builds the IMDb data models on Amazon Athena. The dbt models are the same seven staging, five intermediate and three marts models as in the other four folders, so what this folder shows is the Athena path: the adapter, the connection and the storage.

## What differs from the other folders

- Adapter: `dbt-athena-adapter`, with the `athena_proj` project.
- Connection: an Athena workgroup, reached over the AWS API. There is no cluster, no interactive session and no VPN, so this is the lightest of the five to set up. `set-profile.sh` writes the profile with the workgroup name, the S3 staging directory and `database: awsdatacatalog`.
- Storage: Parquet on S3, registered in the AWS Glue Data Catalog. The seven source tables are created by seven Glue crawlers, one per table, the same as the Glue folder and unlike the two EMR folders. The three marts models set `file_format='parquet'`.
- dbt packages: `dbt-labs/dbt_utils` 0.9.5. The other four folders pin 0.9.2.

## Stack

- Terraform with the AWS provider `>= 3.72`. It creates an S3 bucket, the `imdb` and `imdb_analytics` Glue databases, seven Glue crawlers with a CSV classifier per table, and an Athena workgroup on engine version 2 whose results go to `s3://<default-bucket>/athena/` with SSE-S3 encryption.
- dbt with the `dbt-athena-adapter`.
- `set-profile.sh` derives the region from `aws ec2 describe-availability-zones` but hard-codes `aws_profile_name: cevo`. Change that to your own named AWS profile before running it.
- `axel` is needed by `upload-data.sh`, which downloads the IMDb TSV files.

## How to run

These commands create real AWS resources and they cost money while they exist. Athena bills per query and per byte scanned, and the crawlers and S3 storage are charged too, so destroy the stack when you have finished. Run the commands from this folder.

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
```

Download the IMDb data and copy it to S3, then run the crawlers so the seven source tables appear in the Glue Data Catalog.

```bash
./upload-data.sh
./start-crawlers.sh
```

Install the adapter and write the profile. `set-profile.sh` reads the bucket name and workgroup name from the Terraform outputs and writes `~/.dbt/profiles.yml`.

```bash
pip install dbt-athena-adapter
./set-profile.sh
```

Run the project.

```bash
cd athena_proj
dbt deps
dbt debug
dbt run
dbt test
```

Tear everything down. The S3 bucket is created with `force_destroy = true`, so Terraform empties it for you.

```bash
terraform -chdir=infra destroy
```

## Posts

- [Data Build Tool (dbt) for Effective Data Transformation on AWS – Part 5 Athena](https://jaehyeon.me/blog/2022-12-06-dbt-on-aws-part-5-athena/)

## Back to the repository

[dbt-on-aws](../)
