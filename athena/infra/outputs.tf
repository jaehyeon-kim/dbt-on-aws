# Glue database/crawler
output "imdb_db" {
  description = "Database that contains IMDb staging/intermediate model datasets"
  value       = aws_glue_catalog_database.imdb_db.name
}

output "imdb_db_marts" {
  description = "Database that contains IMDb marts model datasets"
  value       = aws_glue_catalog_database.imdb_db_marts.name
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
output "aws_athena_workgroup_name" {
  description = "Name of Athena workgroup"
  value       = aws_athena_workgroup.imdb.id
}

output "aws_athena_workgroup_arn" {
  description = "ARN of Athena workgroup"
  value       = aws_athena_workgroup.imdb.arn
}

# Default bucket
output "default_bucket_name" {
  description = "Default bucket name"
  value       = aws_s3_bucket.default_bucket.id
}
