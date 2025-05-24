terraform {
  backend "s3" {
    bucket = "resume-website-aws-tfstate-prod"
    key    = "terraform/backend-state"
    region = "us-east-1"
  }
}
