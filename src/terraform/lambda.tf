data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/../build/lambda.zip"
  source_dir  = var.lambda_dir
}

resource "aws_lambda_function" "lambda_func" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "MessageHandler"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      SENDGRID_API_KEY = var.sendgrid_api_key
      EMAIL_FROM       = var.email_from
      DOMAIN           = var.subdomain
    }
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification_topic.arn
}

# Cloudwatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = aws_lambda_function.lambda_func.function_name
  retention_in_days = 14
}