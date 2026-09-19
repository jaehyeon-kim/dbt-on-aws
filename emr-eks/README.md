# dbt on Amazon EMR on EKS

This folder builds the IMDb data models on Amazon EMR on EKS. The dbt models are the same seven staging, five intermediate and three marts models as in the other four folders, so what this folder shows is the EMR on EKS path: the adapter, the connection and the storage.

## What differs from the other folders

- Adapter: `dbt-spark` with the PyHive extra, using the `emr_eks` project. This is the same adapter as EMR on EC2.
- Connection: the Spark Thrift JDBC/ODBC server runs as an EMR on EKS job rather than as a cluster step. Spark Submit will not run the thrift server in cluster mode on Kubernetes, so a wrapper class, `io.jaehyeon.hive.SparkThriftServerRunner`, calls `HiveThriftServer2.main` and then sleeps forever. The driver pod is exposed by a `LoadBalancer` service on port 10001, `resources/spark-thrift-server-service.yaml`, and dbt connects to that service hostname. No VPN is involved, unlike Redshift Serverless and EMR on EC2.
- Storage: Parquet on S3 with the AWS Glue Data Catalog as the metastore, set through `spark.hadoop.hive.metastore.client.factory.class` in `job-run.sh`. The seven source tables are declared as external tables and created by `dbt run-operation stage_external_sources` from the `dbt_external_tables` package, the same as EMR on EC2. The three marts models set `file_format='parquet'`.
- dbt packages: `dbt-labs/dbt_external_tables` 0.8.2 and `dbt-labs/dbt_utils` 0.9.2.

## Stack

- Terraform with the AWS provider `>= 3.72`. It creates a VPC, an S3 bucket, an EKS cluster at version 1.22 with an on-demand `m5.xlarge` managed node group, Karpenter provisioners for the Spark driver and executor pods, and an EMR virtual cluster in the `analytics` namespace.
- EMR release `emr-6.8.0-latest` for the thrift server job.
- `resources/jars/spark-thrift-server-1.0.0-SNAPSHOT.jar` is the prebuilt wrapper class. Its Maven source is in `hive-on-spark-in-kubernetes/`, adapted from a third-party project, see the License section of the repository README. The parent POM that `examples/spark-thrift-server/pom.xml` refers to as `../../pom.xml` is not in this repository, so the prebuilt JAR is the practical starting point.
- `resources/templates/driver-template.yaml` and `executor-template.yaml` are the Spark pod templates, and `resources/test_conn.py` is a small PyHive connection check.
- dbt with the `dbt-spark` adapter. PyHive needs the `libsasl2-dev` system package.
- `axel` is needed by `upload-data.sh`, which downloads the IMDb TSV files.

## How to run

These commands create real AWS resources and they cost money while they exist. The EKS cluster, its node group and the load balancer run continuously until destroyed, so destroy the stack when you have finished. Run the commands from this folder.

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
```

Point `kubectl` at the new cluster. The `configure_kubectl` output prints the `aws eks update-kubeconfig` command to run.

```bash
terraform -chdir=infra output --raw configure_kubectl
```

Download the IMDb data and copy it to S3, then copy the JAR and the pod templates to the same bucket, because `job-run.sh` reads them from `s3://<default-bucket>/resources/`.

```bash
./upload-data.sh
BUCKET=$(terraform -chdir=./infra output --raw default_bucket_name)
aws s3 sync ./resources/jars s3://$BUCKET/resources/jars
aws s3 sync ./resources/templates s3://$BUCKET/resources/templates
```

Start the thrift server job and expose its driver pod.

```bash
./job-run.sh
kubectl apply -f resources/spark-thrift-server-service.yaml
kubectl get svc -n analytics
```

Install dbt and write the profile. `dbt init` asks for the host, which is the `EXTERNAL-IP` of the `spark-thrift-server-service`, the thrift connection method, port 10001 and the `imdb` schema. There is no `set-profile.sh` in this folder.

```bash
sudo apt-get install libsasl2-dev
pip install dbt-core "dbt-spark[PyHive]"
dbt init
```

Create the external source tables, then run the project.

```bash
cd emr_eks
dbt deps
dbt debug
dbt run-operation stage_external_sources
dbt run
dbt test
```

Tear everything down. Delete the service first, so that its load balancer goes away before Terraform tries to remove the VPC.

```bash
kubectl delete -f resources/spark-thrift-server-service.yaml
terraform -chdir=infra destroy
```

## Posts

- [Data Build Tool (dbt) for Effective Data Transformation on AWS – Part 4 EMR on EKS](https://jaehyeon.me/blog/2022-11-01-dbt-on-aws-part-4-emr-eks/)

## Back to the repository

[dbt-on-aws](../)
