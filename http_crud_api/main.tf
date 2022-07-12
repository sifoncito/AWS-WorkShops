terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["$HOME/.aws/credentials"]
  region                   = "us-east-1"
}

# Create a DynamoDB Table
resource "aws_dynamodb_table" "http-crud-tutorial-items" {
  name           = "http-crud-tutorial-items"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Lambda rol
resource "aws_iam_role" "http-crud-tutorial-lambda" {
  name = "iam-crud-tutorial-lambda"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda-logging" {
  name = "lambda_logging"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        "Resource" : "${aws_dynamodb_table.http-crud-tutorial-items.arn}",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_lambda_function" "http-crud-tutorial-function" {
  filename         = "http-crud-tutorial-function.zip"
  function_name    = "http-crud-tutorial-function"
  role             = aws_iam_role.http-crud-tutorial-lambda.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("http-crud-tutorial-function.zip")

  runtime = "nodejs16.x"
  timeout = 10
}

resource "aws_apigatewayv2_api" "http-crud-tutorial-api" {
  name          = "http-crud-tutorial-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "http-crud-api-integration" {
  api_id           = aws_apigatewayv2_api.http-crud-tutorial-api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.http-crud-tutorial-function.invoke_arn
  description      = "Product Collections Lambda Integration"
}

resource "aws_apigatewayv2_stage" "http-crud-api-stage" {
  api_id      = aws_apigatewayv2_api.http-crud-tutorial-api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "get-all" {
  api_id    = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-api-integration.id}"
}

resource "aws_apigatewayv2_route" "get-one" {
  api_id    = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key = "GET /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-api-integration.id}"
}

resource "aws_apigatewayv2_route" "delete-one" {
  api_id    = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key = "DELETE /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-api-integration.id}"
}

resource "aws_apigatewayv2_route" "update" {
  api_id    = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key = "PUT /items"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-api-integration.id}"
}

resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http-crud-tutorial-function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_apigatewayv2_api.http-crud-tutorial-api.execution_arn
}
