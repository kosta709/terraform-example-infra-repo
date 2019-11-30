##
provider "aws" {
  region = var.aws_region
  version = "~> 2.0"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = [for subnet in var.az_subnets: subnet.az]
  public_subnets  = [for subnet in var.az_subnets: subnet.public_subnet_cidr]
  private_subnets = [for subnet in var.az_subnets: subnet.private_subnet_cidr]

  tags = var.common_tags

}
