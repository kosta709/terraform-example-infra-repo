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

data "aws_vpc" "vpc" {
  tags = var.vpc_tags_selector
}

data "aws_security_groups" "private_sg" {
  tags = local.common_tags
  filter {
    name   = "group-name"
    values = [format("%s-private-sg", local.name)]
  }
}

data "aws_security_groups" "public_sg" {
  tags = local.common_tags
  filter {
    name   = "group-name"
    values = [format("%s-public-sg", local.name)]
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = var.private_subnet_names
  }
  tags = local.common_tags
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = var.public_subnet_names
  }
  tags = local.common_tags
}

resource "aws_security_group" "allow_elb_sg" {
  name        = format("%s-allow-elb-sg", local.name)
  description = format("%s - sec group to allow elb access to provate subnets", local.name)
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = data.aws_security_groups.public_sg.ids
  }

  # egress {
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   cidr_blocks     = ["0.0.0.0/0"]
  # }

  tags = merge(
    {"Name" = format("%s-allow-elb-sg", local.name)},
    local.common_tags
  )
}

# Create a new load balancer
resource "aws_elb" "elb" {
  name               = local.name
  subnets = data.aws_subnet_ids.public_subnets.ids
  security_groups = data.aws_security_groups.public_sg.ids

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  cross_zone_load_balancing   = true

  tags = merge(
    {"Name" = local.name},
    local.common_tags
  )
}


resource "aws_key_pair" "key" {
  key_name   = local.name
  public_key = file(format("%s/%s", path.module, "files/ssh-key.pub"))
}

resource "aws_launch_configuration" "lc" {
  name_prefix   = local.name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  user_data = file(format("%s/%s", path.module, "files/web-server-user-data.sh"))
  
  security_groups = [data.aws_security_groups.private_sg.ids[0], aws_security_group.allow_elb_sg.id]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  count = 1
  vpc_zone_identifier = data.aws_subnet_ids.private_subnets.ids
  name = local.name
  launch_configuration = aws_launch_configuration.lc.id

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  #health_check_grace_period = var.health_check_grace_period
  health_check_type         = "EC2"
  load_balancers = [aws_elb.elb.name]
  
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

resource "aws_instance" "sshgw" {
  count = var.sshgw_count
  ami = var.ami_id
  instance_type = "t2.micro"
  key_name = aws_key_pair.key.key_name
  subnet_id = element(tolist(data.aws_subnet_ids.public_subnets.ids), count.index)
  vpc_security_group_ids = data.aws_security_groups.public_sg.ids
  associate_public_ip_address = true
  tags = merge(
    {"Name" = format("%s-sshgw", local.name)},
    local.common_tags
  )
}

output "load_balancer_dns_name" {
  value = aws_elb.elb.dns_name
}

output "sshgw_public_ip" {
  value = aws_instance.sshgw.*.public_ip 
}