locals {
  vpc_name = "VPC-${include.environment.locals.environment}"
  vpc_cidr_block = "10.10.0.0/16"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

include "environment" {
  path = find_in_parent_folders("environment.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=v5.21.0"
}

dependency "aws_azs" {
  config_path = "../aws_availability_zones"
  mock_outputs = {
    azs_names = ["eu-central-5a", "eu-central-5b"]
  }
}

inputs = {
  name = local.vpc_name
  cidr = local.vpc_cidr_block
  azs  = dependency.aws_azs.outputs.azs_names

  private_subnets = [
    for k, v in dependency.aws_azs.outputs.azs_names :
    cidrsubnet(local.vpc_cidr_block, 8, k)
  ]
  public_subnets = [
    for k, v in dependency.aws_azs.outputs.azs_names :
    cidrsubnet(local.vpc_cidr_block, 8, k + 10)
  ]

  enable_nat_gateway = true
  single_nat_gateway = true
  # map_public_ip_on_launch = true

#   vpc_tags = var.vpc_tags
#   tags     = var.tags
}