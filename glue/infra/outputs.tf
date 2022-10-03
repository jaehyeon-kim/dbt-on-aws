# Glue role/policy for interactive session
output "glue_interactive_session_role_arn" {
  description = "ARN of Glue interactive session role"
  value       = aws_iam_role.glue_interactive_session.arn
}

output "glue_interactive_session_policy_arn" {
  description = "ARN of Glue interactive session policy"
  value       = aws_iam_policy.glue_interactive_session.arn
}

output "glue_dbt_policy_arn" {
  description = "ARN of Glue dbt policy"
  value       = aws_iam_policy.glue_dbt.arn
}

# Glue database/crawler
output "glue_database" {
  description = "Glue database name"
  value       = aws_glue_catalog_database.imdb_db.name
}

output "imdb_crawler_name" {
  description = "Name of Glue imdb crawler"
  value = {
    for k, v in aws_glue_crawler.imdb_crawler : k => v.name
  }
}

output "imdb_crawler_arn" {
  description = "ARN of Glue imdb crawler"
  value = {
    for k, v in aws_glue_crawler.imdb_crawler : k => v.arn
  }
}

# Athena
output "aws_athena_workgroup_arn" {
  description = "ARN of Athena workgroup"
  value       = aws_athena_workgroup.imdb.arn
}

# Default bucket
output "default_bucket_name" {
  description = "Default bucket name"
  value       = aws_s3_bucket.default_bucket.id
}
