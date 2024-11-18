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
    echo "DB_PASSWORD=${var.db_password}" >> .env
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

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp"
    }
  }
}