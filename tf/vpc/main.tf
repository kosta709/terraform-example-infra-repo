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