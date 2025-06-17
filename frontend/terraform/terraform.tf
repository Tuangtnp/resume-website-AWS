terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "resume-website-aws-tfstate-prod"
    key    = "terraform/frontend-state"
    region = "us-east-1"
  }
}
