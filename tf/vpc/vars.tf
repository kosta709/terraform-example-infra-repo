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