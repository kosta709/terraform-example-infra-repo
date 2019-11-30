##
variable aws_region {
  description = "aws region for tf provider settings"
  default = "us-east-1"
}

variable "environment" {
  description = "Environment name (production|dev|test|staging)"
  type = string
}

variable vpc_name {
  type = string
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

