## create VPN secrets - IPsec Pre-Shared Key and admin password for VPN
##  see https://cloud.google.com/network-connectivity/docs/vpn/how-to/generating-pre-shared-key
resource "random_password" "vpn_pre_shared_key" {
  length           = 32
  override_special = "/+"
}

resource "random_password" "vpn_admin_pw" {
  length  = 16
  special = false
}

resource "random_password" "redshift_admin_pw" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "all_secrets" {
  name                    = "${local.name}-all-secrets"
  description             = "Service Account Password for the API"
  recovery_window_in_days = 0

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "all_secrets" {
  secret_id     = aws_secretsmanager_secret.all_secrets.id
  secret_string = <<EOF
  {
    "vpn_pre_shared_key": "${random_password.vpn_pre_shared_key.result}",
    "vpn_admin_password": "${random_password.vpn_admin_pw.result}",
    "redshift_admin_username": "${local.redshift.admin_username}",
    "redshift_admin_password": "${random_password.redshift_admin_pw.result}"
  }
EOF
}

data "aws_secretsmanager_secret" "all_secrets" {
  name = aws_secretsmanager_secret.all_secrets.name
}

data "aws_secretsmanager_secret_version" "all_secrets" {
  secret_id = data.aws_secretsmanager_secret.all_secrets.id
}
