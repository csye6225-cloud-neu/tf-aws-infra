resource "aws_db_instance" "rds_instance" {
  identifier           = "csye6225-rds-instance"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  multi_az             = false # No multi-AZ
  allocated_storage    = var.db_allocated_storage
  db_name              = var.db_name
  username             = var.db_username
  password             = random_password.db_password.result # Random password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.rds_param_group.name

  skip_final_snapshot = true
  storage_encrypted   = true
  kms_key_id          = aws_kms_key.rds_key.arn # KMS key for RDS encryption
}

resource "aws_db_parameter_group" "rds_param_group" {
  name   = "csye6225-param-group"
  family = "mysql8.0"

  parameter {
    name  = "max_connections"
    value = "100"
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_kms_key" "rds_key" {
  description              = "KMS key for RDS encryption"
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
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
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
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
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

resource "aws_kms_alias" "rds_kms_key_alias" {
  name          = "alias/rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}