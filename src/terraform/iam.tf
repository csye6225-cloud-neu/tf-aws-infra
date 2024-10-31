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
