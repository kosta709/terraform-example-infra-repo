##
provider "aws" {
  region = var.aws_region
  version = "~> 2.0"
}

locals {
  # Common tags to be assigned to all resources
  name = format("%s-%s", var.environment, var.service_name)
  common_tags = {
    terraform = "true"
    environment = var.environment
    service = var.service_name
  }

  # common_tags_with_name = merge(
  #   {"Name" = local.name}, local.common_tags
  # )
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = [for subnet in var.az_subnets: subnet.az]
  public_subnets  = [for subnet in var.az_subnets: subnet.public_subnet_cidr]
  private_subnets = [for subnet in var.az_subnets: subnet.private_subnet_cidr]

  enable_nat_gateway = true

  tags = local.common_tags

}

resource "aws_key_pair" "key" {
  key_name   = local.name
  public_key = file(format("%s/%s", path.module, "files/ssh-key.pub"))
}

resource "aws_security_group" "private_sg" {
  name        = format("%s-private-sg", local.name)
  description = format("%s - sec group for private subnet instances", local.name)
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(
    {"Name" = format("%s-private-sg", local.name)},
    local.common_tags
  )
}

resource "aws_launch_configuration" "lc" {
  name_prefix   = local.name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  user_data = file(format("%s/%s", path.module, "files/web-server-user-data.sh"))
  
  security_groups = [aws_security_group.private_sg.id]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  count = 1
  vpc_zone_identifier = module.vpc.private_subnets
  name = local.name
  launch_configuration = aws_launch_configuration.lc.id

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  #health_check_grace_period = var.health_check_grace_period
  health_check_type         = "EC2"
  
  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key = tag.key
      value   = tag.value
      propagate_at_launch  = true
    }
  }

}