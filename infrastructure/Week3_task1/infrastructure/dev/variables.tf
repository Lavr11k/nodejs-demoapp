############################################################
#                           VPC                            #
############################################################

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block to use"
  type        = string
}

variable "vpc_private_subnets_amount" {
  description = "Amount of private subnets to create in VPC"
  type        = number
  default     = 2
}

variable "vpc_public_subnets_amount" {
  description = "Amount of public subnets to create in VPC"
  type        = number
  default     = 2
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}
############################################################
#                          ASG                             #
############################################################

variable "asg_name" {
  description = "Name of the ASG"
  type        = string
}

variable "asg_min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 0
}

variable "asg_max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
}

variable "asg_launch_template_name" {
  description = "Name of launch template to be created"
  type        = string
}

variable "asg_launch_template_description" {
  description = "Description of the launch template"
  type        = string
}

variable "asg_user_data_path" {
  description = "the path of user data to provide when launching the instance"
  type        = string
  default     = "../../user_data/user_data.sh"
}

variable "asg_image_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "asg_instance_type" {
  description = "The type of the instance"
  type        = string
  default     = "t2.micro"
}

variable "asg_ebs_root_volume_size" {
  description = "EBS volume size of root volume"
  type        = number
  default     = 5
}

############################################################
#                      Security group                      #
############################################################

variable "web_server_sg_name" {
  description = "Name to be used on web server security group"
  type        = string
}

############################################################
#                            ALB                           #
############################################################

variable "alb_name" {
  description = "Name to be used on ALB"
  type        = string
}

############################################################
#                          Common                          #
############################################################

variable "region" {
  description = "A region to use"
  type        = string
  default     = "eu-central-1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    owner      = "Anastasiia Lavrynovych"
    managed_by = "terraform"
  }
}
