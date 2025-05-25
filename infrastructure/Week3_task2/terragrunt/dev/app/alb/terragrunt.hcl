terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v9.16.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  alb_name = "nodejs-alb"
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id = uuid()
    public_subnets = [uuid(), uuid()]
  }
  
}

inputs = {

  name                       = local.alb_name
  vpc_id                     = dependency.vpc.outputs.vpc_id
  subnets                    = dependency.vpc.outputs.public_subnets
  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    asg = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "asg"
      }
    }
  }

  target_groups = {
    asg = {
      protocol             = "HTTP"
      port                 = 80
      target_type          = "instance"
      deregistration_delay = 5

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "80"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      create_attachment = false
    }
  }
}