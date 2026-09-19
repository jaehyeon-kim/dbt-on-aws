# dbt on AWS Glue

This folder builds the IMDb data models on AWS Glue. The dbt models are the same seven staging, five intermediate and three marts models as in the other four folders, so what this folder shows is the Glue path: the adapter, the connection and the storage.

## What differs from the other folders

- Adapter: `dbt-glue`, with the `dbt_glue_proj` project.
- Connection: a Glue interactive session. There is no cluster and no VPN. dbt assumes the IAM role that Terraform creates for Glue interactive sessions, starts a session with three `G.1X` workers, and submits Spark SQL to it from the developer machine. This is the only folder where the compute is started by dbt itself.
- Storage: Parquet on S3, registered in the AWS Glue Data Catalog. The seven source tables are created by seven Glue crawlers, one per table, not by `dbt_external_tables` as in the two EMR folders. The three marts models set `file_format='parquet'`.
- dbt packages: `dbt-labs/dbt_utils` 0.9.2 only.

## Stack

- Terraform with the AWS provider `>= 3.72`. It creates an S3 bucket, the `imdb` and `imdb_analytics` Glue databases, seven Glue crawlers with a CSV classifier per table, and the IAM role and policies for the interactive session.
- dbt with the `dbt-glue` adapter, plus `boto3` and `aws-glue-sessions` for the session support.
- `set-profile.sh` pins `region: ap-southeast-2` and `glue_version: "3.0"`. Change the region if you deploy elsewhere.
- `axel` is needed by `upload-data.sh`, which downloads the IMDb TSV files.

## How to run

These commands create real AWS resources and they cost money while they exist. Glue interactive sessions bill per session, and the crawlers and S3 storage are charged too, so destroy the stack when you have finished. Run the commands from this folder.

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
```

Download the IMDb data and copy it to S3, then run the crawlers so the seven source tables appear in the Glue Data Catalog.

```bash
./upload-data.sh
./start-crawlers.sh
```

Install the packages. The Glue adapter does not support profile creation through `dbt init`, so the profile is written by `set-profile.sh`, which reads the role ARN and bucket name from the Terraform outputs and writes `~/.dbt/profiles.yml`.

```bash
pip install --no-cache-dir --upgrade boto3 aws-glue-sessions dbt-core dbt-glue
./set-profile.sh
```

Run the project.

```bash
cd dbt_glue_proj
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

- [Data Build Tool (dbt) for Effective Data Transformation on AWS – Part 2 Glue](https://jaehyeon.me/blog/2022-10-09-dbt-on-aws-part-2-glue/)

## Back to the repository

[dbt-on-aws](../)
