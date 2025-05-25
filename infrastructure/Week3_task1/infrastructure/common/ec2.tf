data "aws_ami" "ubuntu_2404" {
  count = var.asg_image_id == "" ? 1 : 0

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305"]
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.16.0"

  name                       = var.alb_name
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
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

  tags = var.tags
}

module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "5.3.0"

  name   = var.web_server_sg_name
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      source_security_group_id = module.alb.security_group_id
      from_port                = 80
      to_port                  = 80
      protocol                 = "TCP"
    }
  ]
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.3.0"

  name = var.asg_name

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.vpc.private_subnets

  traffic_source_attachments = {
    ALB = {
      traffic_source_identifier = [
        for k, v in module.alb.target_groups : v.arn
      ][0]
      traffic_source_type = "elbv2"
    }
  }

  launch_template_name        = var.asg_launch_template_name
  launch_template_description = var.asg_launch_template_description
  key_name                    = "Key-eu-central-1"
  user_data                   = filebase64(var.asg_user_data_path)
  security_groups             = [module.web_server_sg.security_group_id]
  update_default_version      = true

  image_id      = var.asg_image_id == "" ? data.aws_ami.ubuntu_2404[0].id : var.asg_image_id
  instance_type = var.asg_instance_type

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        volume_size           = var.asg_ebs_root_volume_size
        volume_type           = "gp3"
      }
    }
  ]

  tags = var.tags
}
