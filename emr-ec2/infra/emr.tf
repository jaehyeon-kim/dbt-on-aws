## EMR cluster
resource "aws_emr_cluster" "emr_cluster" {
  name                              = "${local.name}-emr-cluster"
  release_label                     = local.emr.release_label
  service_role                      = aws_iam_role.emr_service_role.arn
  autoscaling_role                  = aws_iam_role.emr_autoscaling_role.arn
  applications                      = local.emr.applications
  ebs_root_volume_size              = local.emr.ebs_root_volume_size
  log_uri                           = "s3n://${aws_s3_bucket.default_bucket[0].id}/elasticmapreduce/"
  step_concurrency_level            = 256
  keep_job_flow_alive_when_no_steps = true
  termination_protection            = false

  ec2_attributes {
    key_name                          = aws_key_pair.emr_key_pair.key_name
    instance_profile                  = aws_iam_instance_profile.emr_ec2_instance_profile.arn
    subnet_id                         = element(tolist(module.vpc.private_subnets), 0)
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
    service_access_security_group     = aws_security_group.emr_service_access.id
    additional_master_security_groups = aws_security_group.emr_vpn_access.id
    additional_slave_security_groups  = aws_security_group.emr_vpn_access.id
  }

  master_instance_group {
    instance_type  = local.emr.instance_type
    instance_count = local.emr.instance_count
  }
  core_instance_group {
    instance_type  = local.emr.instance_type
    instance_count = local.emr.instance_count
  }

  configurations_json = <<EOF
    [
      {
          "Classification": "hive-site",
          "Properties": {
              "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
          }
      },
      {
          "Classification": "spark-hive-site",
          "Properties": {
              "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
          }
      }
    ]
  EOF

  tags = local.tags

  depends_on = [module.vpc]
}

resource "aws_emr_managed_scaling_policy" "emr_scaling_policy" {
  cluster_id = aws_emr_cluster.emr_cluster.id

  compute_limits {
    unit_type              = "Instances"
    minimum_capacity_units = 1
    maximum_capacity_units = 5
  }
}

## EMR IAM resources generated based on EMR_DefaultRole
resource "aws_iam_role" "emr_service_role" {
  name               = "${local.name}-emr-service-role"
  assume_role_policy = data.aws_iam_policy_document.emr_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "emr_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "emr_service_role" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

## EMR IAM resources for EC2 generated based on EMR_EC2_DefaultRole
resource "aws_iam_role" "emr_ec2_instance_role" {
  name               = "${local.name}-job-flow-instance-role"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "emr_ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "emr_ec2_instance_role" {
  role       = aws_iam_role.emr_ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "emr_ec2_instance_profile" {
  name = "${local.name}-job-flow-instance-profile"
  role = aws_iam_role.emr_ec2_instance_role.name
}

## EMR IAM resources for auto scaling generated based on EMR_AutoScaling_DefaultRole
resource "aws_iam_role" "emr_autoscaling_role" {
  name               = "${local.name}-emr-autoscaling-role"
  assume_role_policy = data.aws_iam_policy_document.emr_autoscaling_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "emr_autoscaling_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "application-autoscaling.amazonaws.com",
        "elasticmapreduce.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "emr_autoscaling_role" {
  role       = aws_iam_role.emr_autoscaling_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

# Security group resources for master, slace and service access
resource "aws_security_group" "emr_master" {
  vpc_id                 = module.vpc.vpc_id
  name                   = "${local.name}-emr-master"
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "emr_slave" {
  vpc_id                 = module.vpc.vpc_id
  name                   = "${local.name}-emr-slave"
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "emr_service_access" {
  vpc_id                 = module.vpc.vpc_id
  name                   = "${local.name}-emr-service-access"
  revoke_rules_on_delete = true

  ingress {
    description     = "ingress for service access"
    from_port       = 9443
    to_port         = 9443
    protocol        = "tcp"
    security_groups = [aws_security_group.emr_master.id]
  }

  egress {
    description = "egress for service access"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    security_groups = [
      aws_security_group.emr_master.id,
      aws_security_group.emr_slave.id
    ]
  }

  tags = local.tags
}

# security group rules
resource "aws_security_group_rule" "emr_master_tcp_cidr" {
  type              = "ingress"
  description       = "TEMP"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_tcp_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_tcp_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_tcp_svc" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_service_access.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_udp_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_udp_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_icmp_master" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_master_icmp_slave" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_master.id
}

resource "aws_security_group_rule" "emr_slave_tcp_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_slave.id
}

resource "aws_security_group_rule" "emr_slave_tcp_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_slave.id
}

resource "aws_security_group_rule" "emr_slave_tcp_svc" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_service_access.id
  security_group_id        = aws_security_group.emr_slave.id
}

resource "aws_security_group_rule" "emr_slave_udp_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_slave.id
}

resource "aws_security_group_rule" "emr_slave_udp_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_slave.id
}

resource "aws_security_group_rule" "emr_slave_icmp_master" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_slave.id
}

resource "aws_security_group_rule" "emr_slave_icmp_slave" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_slave.id
}

# Security group resources for master, slace and service access
resource "aws_security_group" "emr_vpn_access" {
  name   = "${local.name}-emr-vpn-access"
  vpc_id = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_security_group_rule" "emr_vpn_inbound" {
  count                    = local.vpn.to_create ? 1 : 0
  type                     = "ingress"
  description              = "VPN access"
  security_group_id        = aws_security_group.emr_vpn_access.id
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = aws_security_group.vpn[0].id
}

resource "tls_private_key" "emr_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "emr_key_pair" {
  key_name   = "${local.name}-emr-key"
  public_key = tls_private_key.emr_pk.public_key_openssh
}

resource "local_sensitive_file" "emr_pem_file" {
  filename        = pathexpand("${path.module}/key-pair/${local.name}-emr-key.pem")
  file_permission = "0400"
  content         = tls_private_key.emr_pk.private_key_pem
}
