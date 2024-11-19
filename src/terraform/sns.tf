resource "aws_sns_topic" "user_verification_topic" {
  name = "user-verification-topic"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.user_verification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_func.arn
}