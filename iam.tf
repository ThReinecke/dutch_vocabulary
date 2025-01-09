resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_ssm_ses_policy" {
  name        = "lambda_ssm_ses_access_policy"
  description = "Allows Lambda function to access SSM Parameter Store and send emails via SES"
  policy      = data.aws_iam_policy_document.lambda_ssm_ses_policy_document.json
}

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

resource "aws_iam_role_policy_attachment" "lambda_ssm_ses_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_ssm_ses_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_access_policy"
  description = "Allows Lambda function to access DynamoDB"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_policy_document.json
}

data "aws_iam_policy_document" "lambda_dynamodb_policy_document" {
  statement {
    actions   = ["dynamodb:PutItem", "dynamodb:Scan", "dynamodb:BatchWriteItem"]
    resources = [
        aws_dynamodb_table.words_table.arn,
        "${aws_dynamodb_table.words_table.arn}/index/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
  function_name = aws_lambda_function.vocabulary_lambda.function_name
}
