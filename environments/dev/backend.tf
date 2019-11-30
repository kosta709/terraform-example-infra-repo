terraform {
  backend "s3" {
    bucket = "cfterraformtest123"
    key    = "main-service/test-1"
    region = "us-west-2"
  }
}