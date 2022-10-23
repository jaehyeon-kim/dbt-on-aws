module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.7.0"

  cluster_name    = local.name
  cluster_version = local.eks.cluster_version

  # EKS network config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols, recommended and required for Add-ons"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress, recommended outbound traffic for Node groups"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic, can be restricted further eg, metrics-server 4443, spark-operator 8080, karpenter 8443 ..."
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # EKS manage node groups
  managed_node_groups = {
    ondemand = {
      node_group_name        = local.eks.node_groups.ondemand.name
      instance_types         = local.eks.node_groups.ondemand.instance_types
      subnet_ids             = module.vpc.private_subnets
      max_size               = 5
      min_size               = 1
      desired_size           = 1
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"
      update_config = [{
        max_unavailable_percentage = 30
      }]
      # worker_security_group_ids = [aws_security_group.eks_vpn_access.id]
      tags = local.tags
    }
  }

  # EMR on EKS
  enable_emr_on_eks = true
  emr_on_eks_teams = {
    analytics = {
      namespace               = "analytics"
      job_execution_role      = "analytics-job-execution-role"
      additional_iam_policies = [aws_iam_policy.emr_on_eks.arn]
    }
  }

  tags = local.tags
}

resource "aws_emrcontainers_virtual_cluster" "analytics" {
  name = "${module.eks_blueprints.eks_cluster_id}-analytics"

  container_provider {
    id   = module.eks_blueprints.eks_cluster_id
    type = "EKS"

    info {
      eks_info {
        namespace = "analytics"
      }
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.7.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Addons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  # K8s Addons
  enable_coredns_autoscaler           = true
  enable_metrics_server               = true
  enable_cluster_autoscaler           = true
  enable_karpenter                    = true
  enable_aws_node_termination_handler = true
  enable_aws_load_balancer_controller = true

  tags = local.tags
}

module "karpenter_launch_templates" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/launch-templates?ref=v4.7.0"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  launch_template_config = {
    linux = {
      ami                    = data.aws_ami.eks.id
      launch_template_prefix = "karpenter"
      iam_instance_profile   = module.eks_blueprints.managed_node_group_iam_instance_profile_id[0]
      vpc_security_group_ids = [module.eks_blueprints.worker_node_security_group_id]
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 100
        }
      ]
    }
  }

  tags = merge(local.tags, { Name = "karpenter" })
}

# deploy spark provisioners for Karpenter autoscaler
data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/provisioners/spark*.yaml"
  vars = {
    az           = join(",", slice(local.vpc.azs, 0, 1))
    cluster_name = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value

  depends_on = [module.eks_blueprints_kubernetes_addons]
}

resource "aws_iam_policy" "emr_on_eks" {
  name = "analytics-job-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ]
        Resource = [
          aws_s3_bucket.default_bucket.arn,
          "${aws_s3_bucket.default_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:*",
        ]
        Resource = "*"
      },
    ]
  })
}
