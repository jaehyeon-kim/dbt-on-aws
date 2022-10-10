locals {
  name                 = basename(path.cwd) == "infra" ? basename(dirname(path.cwd)) : basename(path.cwd)
  region               = data.aws_region.current.name
  environment          = "dev"
  to_limit_vpn_ingress = true
  local_ip_address     = "${chomp(data.http.local_ip_address.response_body)}/32"

  vpc = {
    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  }

  vpn = {
    to_create      = true
    to_use_spot    = false
    admin_username = "master"
    ingress_cidr   = local.to_limit_vpn_ingress ? local.local_ip_address : "0.0.0.0/0"
    spot_override = [
      { instance_type : "t3.nano" },
      { instance_type : "t3a.nano" },
    ]
  }

  default_bucket = {
    name = "${local.name}-${data.aws_caller_identity.current.account_id}-${local.region}"
  }

  emr = {
    release_label        = "emr-6.7.0"
    applications         = ["Spark", "Livy", "JupyterEnterpriseGateway", "Hive"]
    instance_type        = "m5.xlarge"
    instance_count       = 1
    ebs_root_volume_size = 80
  }

  secrets = jsondecode(data.aws_secretsmanager_secret_version.all_secrets.secret_string)

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
