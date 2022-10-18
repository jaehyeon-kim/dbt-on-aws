# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

# Region in which to deploy the solution
data "aws_region" "current" {}

# Availability zones to use in our soultion
data "aws_availability_zones" "available" {
  state = "available"
}

# # Local ip address
# data "http" "local_ip_address" {
#   url = "http://ifconfig.co"
# }

# # Latest Amazon linux 2 AMI
# data "aws_ami" "amazon_linux_2" {
#   owners      = ["amazon"]
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-ebs"]
#   }
# }

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
