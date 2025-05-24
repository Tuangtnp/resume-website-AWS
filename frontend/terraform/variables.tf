variable "region" {
  type    = string
  default = "us-east-1"
}

variable "resume_bucket_name" {
  type    = string
  default = "thanaphat.site"
}

variable "resume_domain" {
  type    = string
  default = "thanaphat.site"
}

variable "resume_acm_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:600627329139:certificate/4ea4c817-fb6a-48b7-96f0-a21500abb706"
}
