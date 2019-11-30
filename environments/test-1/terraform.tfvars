aws_region = "us-west-2"

environment = "test-1"

vpc_name = "test-1-main-service"
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