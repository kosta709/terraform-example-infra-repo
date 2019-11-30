terraform {
  backend "s3" {
    bucket = "cfterraformtest123"
    key    = "infra/main-service/dev"
    region = "us-west-2"
  }
}