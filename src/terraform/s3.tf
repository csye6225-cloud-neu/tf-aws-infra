resource "aws_s3_bucket" "csye6225_bucket" {
  bucket        = uuid()
  force_destroy = true

  tags = {
    Name = "csye6225_bucket"
  }
}

# Lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" {
  bucket = aws_s3_bucket.csye6225_bucket.id

  rule {
    id     = "TransitionToStandardIA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_kms_key" "s3_bucket_key" {
  description             = "KMS key for S3 bucket encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7
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
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        Resource : "*"
      },
      {
        Sid : "Allow attachment of persistent resources",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "csye6225_bucket_sse" {
  bucket = aws_s3_bucket.csye6225_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_alias" "s3_bucket_key_alias" {
  name          = "alias/s3_bucket"
  target_key_id = aws_kms_key.s3_bucket_key.key_id
}