terraform {
  backend "s3" {
    bucket = "cfterraformtest123"
    key    = "infra/vpc/dev"
    region = "us-west-2"
  }
}