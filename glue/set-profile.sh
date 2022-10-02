#!/usr/bin/env bash

export DBT_ROLE_ARN=$(terraform -chdir=./infra output --raw glue_interactive_session_role_arn)
export DBT_S3_LOCATION=$(terraform -chdir=./infra output --raw default_bucket_name)

cat << EOF > ~/.dbt/profiles.yml
dbt_glue_proj:
  outputs:
    dev:
      type: glue
      role_arn: "${DBT_ROLE_ARN}"
      region: ap-southeast-2
      workers: 3
      worker_type: G.1X
      schema: imdb
      database: imdb
      session_provisioning_timeout_in_seconds: 120
      location: "${DBT_S3_LOCATION}"
      query_timeout_in_seconds: 300
      idle_timeout: 60
      glue_version: "3.0"
  target: dev
EOF