export VIRTUAL_CLUSTER_ID=$(terraform -chdir=./infra output --raw emrcontainers_virtual_cluster_id)
export EMR_ROLE_ARN=$(terraform -chdir=./infra output --json emr_on_eks_role_arn | jq '.[0]' -r)
export DEFAULT_BUCKET_NAME=$(terraform -chdir=./infra output --raw default_bucket_name)
export AWS_REGION=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].[RegionName]' --output text)

aws emr-containers start-job-run \
--virtual-cluster-id $VIRTUAL_CLUSTER_ID \
--name thrift-server \
--execution-role-arn $EMR_ROLE_ARN \
--release-label emr-6.8.0-latest \
--region $AWS_REGION \
--job-driver '{
    "sparkSubmitJobDriver": {
        "entryPoint": "s3://'${DEFAULT_BUCKET_NAME}'/resources/jars/spark-thrift-server-1.0.0-SNAPSHOT.jar",
        "sparkSubmitParameters": "--class io.jaehyeon.hive.SparkThriftServerRunner --jars s3://'${DEFAULT_BUCKET_NAME}'/resources/jars/spark-thrift-server-1.0.0-SNAPSHOT.jar --conf spark.executor.instances=2 --conf spark.executor.memory=1G --conf spark.executor.cores=1 --conf spark.driver.cores=1"
        }
    }' \
--configuration-overrides '{
    "applicationConfiguration": [
      {
        "classification": "spark-defaults", 
        "properties": {
          "spark.dynamicAllocation.enabled":"false",
          "spark.kubernetes.executor.deleteOnTermination": "true",
          "spark.kubernetes.driver.podTemplateFile":"s3://'${DEFAULT_BUCKET_NAME}'/resources/templates/driver-template.yaml", 
          "spark.kubernetes.executor.podTemplateFile":"s3://'${DEFAULT_BUCKET_NAME}'/resources/templates/executor-template.yaml",
          "spark.hadoop.hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
         }
      }
    ]
}'