resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name        = "daily_lambda_trigger"
  description = "Trigger Lambda function once a day"
  schedule_expression = "cron(0 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  arn       = aws_lambda_function.vocabulary_lambda.arn
  target_id = "daily_lambda_target"
}
