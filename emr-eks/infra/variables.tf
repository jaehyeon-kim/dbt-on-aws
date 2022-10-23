locals {
  name        = basename(path.cwd) == "infra" ? basename(dirname(path.cwd)) : basename(path.cwd)
  region      = data.aws_region.current.name
  environment = "dev"
  # to_limit_vpn_ingress = true
  # local_ip_address     = "${chomp(data.http.local_ip_address.response_body)}/32"

  vpc = {
    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  }

  default_bucket = {
    name = "${local.name}-default-${data.aws_caller_identity.current.account_id}-${local.region}"
  }

  eks = {
    cluster_version = "1.22"
    node_groups = {
      ondemand = {
        name           = "managed-ondemand"
        instance_types = ["m5.xlarge"]
      }
    }
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
