module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14"

  name = "${local.name}-vpc"
  cidr = local.vpc.cidr

  azs             = local.vpc.azs
  public_subnets  = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 3, k)]
  private_subnets = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 3, k + 3)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  create_igw           = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
    "karpenter.sh/discovery"              = local.name
  }

  tags = local.tags
}

# default bucket
resource "aws_s3_bucket" "default_bucket" {
  bucket = local.default_bucket.name

  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_acl" "default_bucket" {
  bucket = aws_s3_bucket.default_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default_bucket" {
  bucket = aws_s3_bucket.default_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# athena workgroup
resource "aws_athena_workgroup" "imdb" {
  name = "${local.name}-imdb"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${local.default_bucket.name}/athena/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  force_destroy = true

  tags = local.tags
}

# glue databases
resource "aws_glue_catalog_database" "imdb_db" {
  name         = "imdb"
  location_uri = "s3://${local.default_bucket.name}/imdb"
  description  = "Database that contains IMDb staging/intermediate model datasets"
}

resource "aws_glue_catalog_database" "imdb_db_marts" {
  name         = "imdb_analytics"
  location_uri = "s3://${local.default_bucket.name}/imdb_analytics"
  description  = "Database that contains IMDb marts model datasets"
}
