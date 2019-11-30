terraform {
  backend "s3" {
    bucket = "cfterraformtest123"
    key    = "infra/main-service/test-1"
    region = "us-west-2"
  }
}