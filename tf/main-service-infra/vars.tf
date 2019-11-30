##
variable aws_region {
  description = "aws region for tf provider settings"
  default = "us-east-1"
}

variable "environment" {
  description = "Environment name (production|dev|test|staging)"
  type = string
}

variable "service_name" {
  description = "service name"
  default = "main-service"
}

variable vpc_cidr {
  type = string
}

variable az_subnets {
  type = list(object(
    {
      az = string
      public_subnet_cidr = string
      private_subnet_cidr = string
    }
  ))
}

variable "ami_id" {
  description = "aws ami id "
}

variable "instance_type" {
  default = "t2.micro"
}

variable "asg_min_size" {
  default = 1
}

variable "asg_desired_capacity" {
  default = 2
}

variable "asg_max_size" {
  default = 10
}