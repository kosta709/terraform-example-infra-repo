aws_region = "us-west-2"

environment = "dev"

vpc_name = "dev-main-service"
vpc_cidr = "10.100.0.0/16"

az_subnets = [
  {
    az = "us-west-2a"
    public_subnet_cidr = "10.100.0.0/24"
    private_subnet_cidr = "10.100.100.0/24"
  },
  {
    az = "us-west-2b"
    public_subnet_cidr = "10.100.1.0/24"
    private_subnet_cidr = "10.100.101.0/24"
  }
]