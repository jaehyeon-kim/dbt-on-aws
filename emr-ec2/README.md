# dbt on Amazon EMR on EC2

This folder builds the IMDb data models on an Amazon EMR cluster running on EC2. The dbt models are the same seven staging, five intermediate and three marts models as in the other four folders, so what this folder shows is the EMR on EC2 path: the adapter, the connection and the storage.

## What differs from the other folders

- Adapter: `dbt-spark` with the PyHive extra, using the `emr_ec2` project.
- Connection: the Spark Thrift JDBC/ODBC server, started as an EMR step on the cluster master and listening on port 10001. The cluster sits in a private subnet, so the developer machine reaches it through a SoftEther VPN server that the same Terraform creates. The VPN credentials are generated in Terraform and stored in AWS Secrets Manager, see `infra/secrets.tf`. The EMR on EKS folder uses the same adapter but reaches the thrift server through a Kubernetes service instead.
- Storage: Parquet on S3 with the AWS Glue Data Catalog as the Hive and Spark SQL metastore. The seven source tables are declared as external tables in `emr_ec2/models/staging/imdb/_imdb__sources.yml` with an OpenCSV serde, and created by `dbt run-operation stage_external_sources` from the `dbt_external_tables` package. There are no Glue crawlers here. The three marts models set `file_format='parquet'`.
- dbt packages: `dbt-labs/dbt_external_tables` 0.8.2 and `dbt-labs/dbt_utils` 0.9.2.

## Stack

- Terraform with the AWS provider `>= 3.72`. It creates a VPC, a SoftEther VPN autoscaling group, an S3 bucket, a Secrets Manager secret, the `imdb` and `imdb_analytics` Glue databases, and an EMR cluster.
- EMR release `emr-6.7.0` with Spark, Livy, JupyterEnterpriseGateway and Hive, one `m5.xlarge` master and one `m5.xlarge` core instance, and a managed scaling policy that adds up to four task instances.
- dbt with the `dbt-spark` adapter. PyHive needs the `libsasl2-dev` system package.
- `axel` is needed by `upload-data.sh`, which downloads the IMDb TSV files.

## How to run

These commands create real AWS resources and they cost money while they exist. The EMR cluster and the VPN instance run continuously until destroyed, so destroy the stack when you have finished. Run the commands from this folder.

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
```

Download the IMDb data and copy it to S3.

```bash
./upload-data.sh
```

Start the Spark Thrift Server as an EMR step.

```bash
CLUSTER_ID=$(terraform -chdir=./infra output --raw emr_cluster_id)
aws emr add-steps \
  --cluster-id $CLUSTER_ID \
  --steps Type=CUSTOM_JAR,Name="spark thrift server",ActionOnFailure=CONTINUE,Jar=command-runner.jar,Args=[sudo,/usr/lib/spark/sbin/start-thriftserver.sh]
```

Connect to the VPN server, then install dbt and write the profile. `dbt init` asks for the host, which is the master instance private DNS name from `terraform -chdir=./infra output --raw emr_cluster_master_dns`, the thrift connection method, port 10001 and the `imdb` schema. There is no `set-profile.sh` in this folder.

```bash
sudo apt-get install libsasl2-dev
pip install dbt-core "dbt-spark[PyHive]"
dbt init
```

Create the external source tables, then run the project. The VPN connection has to stay up throughout.

```bash
cd emr_ec2
dbt deps
dbt debug
dbt run-operation stage_external_sources
dbt run
dbt test
```

Tear everything down.

```bash
terraform -chdir=infra destroy
```

## Posts

- [Data Build Tool (dbt) for Effective Data Transformation on AWS – Part 3 EMR on EC2](https://jaehyeon.me/blog/2022-10-19-dbt-on-aws-part-3-emr-ec2/)

## Back to the repository

[dbt-on-aws](../)
