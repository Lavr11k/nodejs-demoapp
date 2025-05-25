include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-autoscaling//.?ref=v8.3.0"
}

locals {
  asg_name = "nodejs-asg"
  asg_min_size = 0
  asg_max_size = 1
  asg_desired_capacity = 1
  asg_launch_template_name = "nodejs-lt"
  asg_launch_template_description = "Launch template for a simple NodeJS application using docker inside"
  sg_user_data_path = "./user_data.sh"
  asg_ebs_root_volume_size = 5
  asg_image_id = "ami-03250b0e01c28d196"
  asg_instance_type = "t2.micro"
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    private_subnets =[uuid(), uuid()]
  }
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    target_groups = {
      asg = {
        arn = uuid()
      }
    }
  }
}

dependency "web_server_sg" {
  config_path = "../sg"
  mock_outputs = {
    security_group_id = uuid()
  }
}

inputs = {
  
  name = local.asg_name

  min_size                  = local.asg_min_size
  max_size                  = local.asg_max_size
  desired_capacity          = local.asg_desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = dependency.vpc.outputs.private_subnets

  traffic_source_attachments = {
    ALB = {
      traffic_source_identifier = [
        for k, v in dependency.alb.outputs.target_groups : v.arn
      ][0]
      traffic_source_type = "elbv2"
    }
  }

  launch_template_name        = local.asg_launch_template_name
  launch_template_description = local.asg_launch_template_description
  key_name                    = "Key-eu-central-1"
  user_data                   = filebase64(local.sg_user_data_path)
  security_groups             = [dependency.web_server_sg.outputs.security_group_id]
  update_default_version      = true

  image_id      = local.asg_image_id
  instance_type = local.asg_instance_type

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        volume_size           = local.asg_ebs_root_volume_size
        volume_type           = "gp3"
      }
    }
  ]
}
