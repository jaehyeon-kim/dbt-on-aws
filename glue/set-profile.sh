#!/usr/bin/env bash

dbt_role_arn=$(terraform -chdir=./infra output --raw glue_interactive_session_role_arn)
dbt_s3_location=$(terraform -chdir=./infra output --raw default_bucket_name)

cat << EOF > ~/.dbt/profiles.yml
dbt_glue_proj:
  outputs:
    dev:
      type: glue
      role_arn: "${dbt_role_arn}"
      region: ap-southeast-2
      workers: 3
      worker_type: G.1X
      schema: imdb
      database: imdb
      session_provisioning_timeout_in_seconds: 120
      location: "${dbt_s3_location}"
      query_timeout_in_seconds: 300
      idle_timeout: 60
      glue_version: "3.0"
  target: dev
EOF