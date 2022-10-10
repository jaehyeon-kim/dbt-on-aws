# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# AZs
output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = module.vpc.azs
}

# AutoScaling
output "vpn_launch_template_arn" {
  description = "The ARN of the VPN launch template"
  value = {
    for k, v in module.vpn : k => v.launch_template_arn
  }
}

output "vpn_autoscaling_group_id" {
  description = "VPN autoscaling group id"
  value = {
    for k, v in module.vpn : k => v.autoscaling_group_id
  }
}

output "vpn_autoscaling_group_name" {
  description = "VPN autoscaling group name"
  value = {
    for k, v in module.vpn : k => v.autoscaling_group_name
  }
}

# Default bucket
output "data_bucket_name" {
  description = "Default bucket name"
  value = {
    for k, v in aws_s3_bucket.default_bucket : k => v.id
  }
}

# EMR
output "emr_cluster_id" {
  description = "EMR cluster ID"
  value       = aws_emr_cluster.emr_cluster.id
}

output "emr_cluster_name" {
  description = "EMR cluster name"
  value       = aws_emr_cluster.emr_cluster.name
}

output "emr_cluster_master_dns" {
  description = "EMR cluster master DNS name"
  value       = aws_emr_cluster.emr_cluster.master_public_dns
}

output "emr_service_role" {
  description = "EMR service role name"
  value       = aws_iam_role.emr_service_role.name
}

output "emr_instance_role" {
  description = "EMR instance role name"
  value       = aws_iam_role.emr_ec2_instance_role.name
}

output "emr_instance_profile" {
  description = "EMR instance profile name"
  value       = aws_iam_instance_profile.emr_ec2_instance_profile.name
}

output "emr_autoscaling_role" {
  description = "EMR autoscaling role name"
  value       = aws_iam_role.emr_autoscaling_role.name
}

output "emr_master_sg" {
  description = "EMR cluster master sg"
  value       = aws_security_group.emr_master.id
}

output "emr_slave_sg" {
  description = "EMR cluster slave sg"
  value       = aws_security_group.emr_slave.id
}

output "emr_vpn_access_sg" {
  description = "EMR cluster VPN access sg"
  value       = aws_security_group.emr_vpn_access.id
}
