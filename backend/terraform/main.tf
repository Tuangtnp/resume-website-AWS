resource "aws_dynamodb_table" "resume_visitor_counter_table" {
  name         = var.resume_counter_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_dynamodb_table_item" "resume_visitor_counter_item" {
  table_name = aws_dynamodb_table.resume_visitor_counter_table.name
  hash_key   = aws_dynamodb_table.resume_visitor_counter_table.hash_key

  item = jsonencode({
    "id" : { "S" : "resume" },
    "visits" : { "N" : "0" }
  })
}

resource "aws_iam_role" "resume_lambda_execution_role" {
  name = var.resume_lambda_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_iam_policy" "resume_lambda_dynamodb_policy" {
  name        = var.resume_lambda_dynamodb_policy_name
  description = "IAM policy allow Lambda to update and get items from DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.resume_visitor_counter_table.arn
      }
    ]
  })

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "resume_lambda_policy_attachment" {
  role       = aws_iam_role.resume_lambda_execution_role.name
  policy_arn = aws_iam_policy.resume_lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "resume_lambda_logging_attachment" {
  role       = aws_iam_role.resume_lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "resume_visitor_counter_function" {
  function_name    = var.resume_lambda_name
  handler          = "${var.resume_lambda_handler_file}.${var.resume_lambda_handler_function}"
  runtime          = var.resume_lambda_runtime
  role             = aws_iam_role.resume_lambda_execution_role.arn
  filename         = var.resume_lambda_path
  source_code_hash = filebase64sha256(var.resume_lambda_path)

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_apigatewayv2_api" "resume_counter_api" {
  name          = var.resume_api_name
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_apigatewayv2_integration" "resume_lambda_integration" {
  api_id           = aws_apigatewayv2_api.resume_counter_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.resume_visitor_counter_function.invoke_arn
}

resource "aws_apigatewayv2_route" "resume_counter_route" {
  api_id    = aws_apigatewayv2_api.resume_counter_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.resume_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "resume_api_stage_default" {
  api_id      = aws_apigatewayv2_api.resume_counter_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_lambda_permission" "resume_lambda_allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume_visitor_counter_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_counter_api.execution_arn}/*/*"
}
