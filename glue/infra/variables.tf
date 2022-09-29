locals {
  name        = basename(path.cwd) == "infra" ? basename(dirname(path.cwd)) : basename(path.cwd)
  region      = data.aws_region.current.name
  environment = "dev"

  default_bucket = {
    name = "${local.name}-${data.aws_caller_identity.current.account_id}-${local.region}"
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
