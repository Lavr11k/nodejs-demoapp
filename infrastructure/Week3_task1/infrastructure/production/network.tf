locals {
  vpc_azs = slice(data.aws_availability_zones.availability_zones.names, 0, max(
    var.vpc_private_subnets_amount, var.vpc_public_subnets_amount
  ))
}

data "aws_availability_zones" "availability_zones" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr_block
  azs  = local.vpc_azs

  private_subnets = [
    for k, v in slice(local.vpc_azs, 0, var.vpc_private_subnets_amount) :
    cidrsubnet(var.vpc_cidr_block, 8, k)
  ]
  public_subnets = [
    for k, v in slice(local.vpc_azs, 0, var.vpc_public_subnets_amount) :
    cidrsubnet(var.vpc_cidr_block, 8, k + 10)
  ]

  enable_nat_gateway = true
  single_nat_gateway = true
  # map_public_ip_on_launch = true

  vpc_tags = var.vpc_tags
  tags     = var.tags
}
