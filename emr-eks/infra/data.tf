# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

# Region in which to deploy the solution
data "aws_region" "current" {}

# Availability zones to use in our soultion
data "aws_availability_zones" "available" {
  state = "available"
}

# ESK cluster authentication token
data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

# Latest Amazon linux AMI for EKS launch template
data "aws_ami" "eks" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${module.eks_blueprints.eks_cluster_version}-*"]
  }
}
