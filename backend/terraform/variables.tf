variable "region" {
  type    = string
  default = "us-east-1"
}

variable "resume_lambda_name" {
  type    = string
  default = "resume-visitor-counter"
}

variable "resume_lambda_handler_file" {
  type    = string
  default = "visitor-counter"
}

variable "resume_lambda_handler_function" {
  type    = string
  default = "lambda_handler"
}

variable "resume_lambda_runtime" {
  type    = string
  default = "python3.13"
}

variable "resume_lambda_path" {
  type    = string
  default = "../lambda/visitor-counter.zip"
}

variable "resume_lambda_execution_role_name" {
  type    = string
  default = "resume-lambda-exec-role"
}

variable "resume_lambda_dynamodb_policy_name" {
  type    = string
  default = "resume-lambda-dynamodb-policy"
}

variable "resume_counter_table_name" {
  type    = string
  default = "resume-visitor-count-DB"
}

variable "resume_api_name" {
  type    = string
  default = "resume-counter-API"
}
