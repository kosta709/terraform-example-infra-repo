terraform {
  backend "s3" {
    bucket = "cfterraformtest123"
    key    = "main-service/dev"
    region = "us-west-2"
  }
}