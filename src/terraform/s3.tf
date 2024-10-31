resource "aws_s3_bucket" "csye6225_bucket" {
  # bucket_prefix = "csye6225-bucket-"
  bucket        = "csye6225-fall2024-bucket-pinkaew"
  force_destroy = true

  tags = {
    Name        = "csye6225_bucket"
    Environment = "Dev"
  }
}

# Default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "csye6225_bucket_sse" {
  bucket = aws_s3_bucket.csye6225_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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

resource "aws_iam_policy" "delete_non_empty_bucket" {
  name        = "AllowDeleteNonEmptyBucket"
  description = "Policy to allow deletion of non-empty S3 buckets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:DeleteBucket",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${aws_s3_bucket.csye6225_bucket.bucket}"
      },
      {
        Action   = "s3:DeleteObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${aws_s3_bucket.csye6225_bucket.bucket}/*"
      }
    ]
  })
}