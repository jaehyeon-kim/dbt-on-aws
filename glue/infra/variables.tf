# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

# Region in which to deploy the solution
data "aws_region" "current" {}

locals {
  name        = basename(path.cwd) == "infra" ? basename(dirname(path.cwd)) : basename(path.cwd)
  region      = data.aws_region.current.name
  environment = "dev"

  default_bucket = {
    name = "${local.name}-${data.aws_caller_identity.current.account_id}-${local.region}"
  }

  glue = {
    s3_prefixes = [
      "s3://${local.default_bucket.name}/name_basics",
      "s3://${local.default_bucket.name}/title_akas",
      "s3://${local.default_bucket.name}/title_basics",
      "s3://${local.default_bucket.name}/title_crew",
      "s3://${local.default_bucket.name}/title_episode",
      "s3://${local.default_bucket.name}/title_principals",
      "s3://${local.default_bucket.name}/title_ratings"
    ]
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
