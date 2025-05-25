terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//modules/http-80?ref=v5.3.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  sg_name = "webserver-sg"
}

inputs = {
  name   = local.sg_name
  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      source_security_group_id = dependency.alb.outputs.security_group_id
      from_port                = 80
      to_port                  = 80
      protocol                 = "TCP"
    }
  ]
}
dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id = uuid()
  }
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    security_group_id = uuid()
  }
}