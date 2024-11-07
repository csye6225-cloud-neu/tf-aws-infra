resource "aws_s3_bucket" "csye6225_bucket" {
  # bucket_prefix = "csye6225-bucket-"
  bucket        = uuid()
  force_destroy = true

  tags = {
    Name = "csye6225_bucket"
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