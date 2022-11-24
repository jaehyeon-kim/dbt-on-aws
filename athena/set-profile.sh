#!/usr/bin/env bash

aws_region=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
dbt_s3_location=$(terraform -chdir=./infra output --raw default_bucket_name)
dbt_work_group=$(terraform -chdir=./infra output --raw aws_athena_workgroup_name)

cat << EOF > ~/.dbt/profiles.yml
athena_proj:
  outputs:
    dev:
      type: athena
      region_name: ${aws_region}
      s3_staging_dir: "s3://${dbt_s3_location}/dbt/"
      schema: imdb
      database: awsdatacatalog
      work_group: ${dbt_work_group}
      threads: 3
      aws_profile_name: cevo
  target: dev
EOF