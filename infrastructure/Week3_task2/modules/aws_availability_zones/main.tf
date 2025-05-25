locals {
  azs_names = slice(data.aws_availability_zones.availability_zones.names, 0, var.azs_amount)
}

data "aws_availability_zones" "availability_zones" {}
