resource "aws_launch_template" "csye6225_launch_template" {
  name          = "csye6225_launch_template"
  image_id      = var.ami_id
  key_name      = var.ami_key_name
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_instance_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    cd /opt/webapp
    touch .env
    echo "DB_HOST=${aws_db_instance.rds_instance.address}" >> .env
    echo "DB_USERNAME=${var.db_username}" >> .env
    echo "DB_PASSWORD=${random_password.db_password.result}" >> .env
    echo "DB_NAME=${var.db_name}" >> .env
    echo "DB_DIALECT=${var.dialect}" >> .env
    echo "PORT=${var.app_port}" >> .env
    echo "AWS_ACCESS_KEY_ID=${var.aws_access_key}" >> .env
    echo "AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}" >> .env
    echo "AWS_REGION=${var.aws_region}" >> .env
    echo "S3_BUCKET_NAME=${aws_s3_bucket.csye6225_bucket.bucket}" >> .env
    echo "SNS_TOPIC_ARN=${aws_sns_topic.user_verification_topic.arn}" >> .env

    chmod 600 .env
    chown -R csye6225:csye6225 .env

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c file:/opt/cloudwatch-agent.json \
        -s
    sudo systemctl restart amazon-cloudwatch-agent
  EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
      kms_key_id  = aws_kms_key.launch_template_key.arn
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "launch_template_key" {
  description             = "KMS key for EC2 launch template"
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
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
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
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
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

resource "aws_kms_alias" "launch_template_kms_key_alias" {
  name          = "alias/launch-template-key"
  target_key_id = aws_kms_key.launch_template_key.key_id
}