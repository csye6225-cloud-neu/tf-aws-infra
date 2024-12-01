resource "aws_kms_key" "secrets_manager" {
  description              = "KMS key for Secrets Manager"
  enable_key_rotation      = true
  rotation_period_in_days  = 90
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid : "Allow use of the key",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Lambda-Role"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      },
      {
        Sid : "Allow attachment of persistent resources",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Lambda-Role"
        },
        Action : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource : "*",
        Condition : {
          Bool : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "secrets_kms_key_alias" {
  name          = "alias/secrets-manager"
  target_key_id = aws_kms_key.secrets_manager.key_id
}

# AWS Secrets Manager for RDS password
resource "aws_secretsmanager_secret" "db_password_secret" {
  name = "database_password"
  kms_key_id  = aws_kms_key.secrets_manager.key_id
  description = "Password for RDS"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password_secret.id
  secret_string = jsonencode({
    password = random_password.db_password.result
  })
}

# AWS Secrets Manager for Sendgrid API key
resource "aws_secretsmanager_secret" "api_key_secret" {
  name        = "sendgrid_api_key"
  kms_key_id  = aws_kms_key.secrets_manager.key_id
  description = "API key for Sendgrid"
}

resource "aws_secretsmanager_secret_version" "email_service_secret_version" {
  secret_id = aws_secretsmanager_secret.api_key_secret.id
  secret_string = jsonencode({
    apikey = var.sendgrid_api_key
  })
}