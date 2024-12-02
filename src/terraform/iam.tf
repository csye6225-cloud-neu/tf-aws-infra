# The IAM role for the CloudWatch agent
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "CloudWatchAgentServerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      }
    ]
  })
}

# Attach the permissions policy to the role
resource "aws_iam_policy" "cloudwatch_s3_policy" {
  name = "CloudWatch_S3Access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${aws_s3_bucket.csye6225_bucket.bucket}/*"
      }
    ]
  })
}

# Attach the CloudWatch agent server policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# An instance profile for the CloudWatch agent role
resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "cloudwatch_agent_instance_profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# An IAM role for publishing to the SNS topic
resource "aws_iam_role" "sns_publish_role" {
  name = "SNSPublishRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "sns_publish_policy" {
  name = "SNSPublishPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.user_verification_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
  role       = aws_iam_role.sns_publish_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

# An IAM role for the Lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "Lambda-Role"
  # assume_role_policy = data.aws_iam_policy_document.assume_role.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_rds" {
  name = "LambdaRDSAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds-db:connect"
        ],
        Effect   = "Allow",
        Resource = aws_db_instance.rds_instance.arn
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_secrets" {
  name        = "LambdaSecretsAccessPolicy"
  description = "Allow Lambda to access Sendgrid API key in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.api_key_secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rds" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_rds.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_secrets.arn
}