# Glue IAM role/policy
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

# athena
output "aws_athena_workgroup_arn" {
  description = "ARN of Athena workgroup"
  value       = aws_athena_workgroup.dbt.arn
}

# Default bucket
output "data_bucket_name" {
  description = "Default bucket name"
  value       = aws_s3_bucket.default_bucket.id
}
