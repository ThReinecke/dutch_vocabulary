terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.82.2"
    }
  }
  required_version = ">= 1.10.3"
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# Lambda where everything runs on
resource "aws_lambda_function" "vocabulary_lambda" {
  function_name    = "VocabularyLambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = "deployment_package.zip"
  source_code_hash = filebase64sha256("deployment_package.zip")
  timeout          = 10
}
