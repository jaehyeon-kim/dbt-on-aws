# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

# Region in which to deploy the solution
data "aws_region" "current" {}

# Availability zones to use in our soultion
data "aws_availability_zones" "available" {
  state = "available"
}
