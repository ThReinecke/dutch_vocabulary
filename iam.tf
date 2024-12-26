
# IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# IAM policy document for allowing Lambda to assume the role
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Create an IAM policy to allow access to SSM Parameter Store and SES
resource "aws_iam_policy" "lambda_ssm_ses_policy" {
  name        = "lambda_ssm_ses_access_policy"
  description = "Allows Lambda function to access SSM Parameter Store and send emails via SES"
  policy      = data.aws_iam_policy_document.lambda_ssm_ses_policy_document.json
}

# IAM policy document for allowing Lambda to access SSM and SES
data "aws_iam_policy_document" "lambda_ssm_ses_policy_document" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/OPEN_AI_API_KEY",
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/EMAIL_FOR_SES"
    ]
  }

  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [
      "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/${var.ses_email}"
    ]
  }
}

# Attach the SSM and SES access policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ssm_ses_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_ssm_ses_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

# Create an IAM policy to allow access to DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_access_policy"
  description = "Allows Lambda function to access DynamoDB"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_policy_document.json
}

# IAM policy document for allowing Lambda to access DynamoDB
data "aws_iam_policy_document" "lambda_dynamodb_policy_document" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchWriteItem"]
    resources = [
        aws_dynamodb_table.words_table.arn,
        "${aws_dynamodb_table.words_table.arn}/index/*"
    ]
  }
}

# Attach the DynamoDB access policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

# Add permissions for CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
  function_name = aws_lambda_function.hello_world_lambda.function_name
}