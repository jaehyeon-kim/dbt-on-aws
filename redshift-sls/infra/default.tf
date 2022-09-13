module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14"

  name = "${local.name}-vpc"
  cidr = local.vpc.cidr

  azs             = local.vpc.azs
  public_subnets  = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 3, k)]
  private_subnets = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 3, k + 3)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  tags = local.tags
}

resource "aws_s3_bucket" "default_bucket" {
  count = local.default_bucket.to_create ? 1 : 0

  bucket = local.default_bucket.name

  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_acl" "default_bucket" {
  count = local.default_bucket.to_create ? 1 : 0

  bucket = aws_s3_bucket.default_bucket[0].id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default_bucket" {
  count = local.default_bucket.to_create ? 1 : 0

  bucket = aws_s3_bucket.default_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
