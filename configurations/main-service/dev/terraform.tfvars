aws_region = "us-west-2"

environment = "dev"

ami_id = "ami-06d51e91cea0dac8d"

vpc_tags_selector = {
  Name = "dev-main-service"
  environment = "dev"
  service = "main-service"
  terraform = "true"
} 

public_subnet_names =  [
  "dev-main-service-public-us-west-2a",
  "dev-main-service-public-us-west-2b"
]

private_subnet_names =  [
  "dev-main-service-private-us-west-2a",
  "dev-main-service-private-us-west-2b"
]

private_security_group_names = ["dev-main-service-private-sg"]
public_security_group_names = ["dev-main-service-public-sg"]

