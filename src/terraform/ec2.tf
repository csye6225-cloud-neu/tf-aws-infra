resource "aws_instance" "webapp" {
  ami                         = var.ami_id
  key_name                    = var.ami_key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = values(aws_subnet.public_subnets)[0].id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_instance_profile.name

  root_block_device {
    volume_size           = var.ec2_volume_size
    volume_type           = var.ec2_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = "webapp-instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    ####################################################
    # Create .env file for environment variables       #
    ####################################################
    cd /opt/webapp
    touch .env
    echo "DB_HOST=$(echo ${aws_db_instance.rds_instance.endpoint} | cut -d':' -f1)" >> .env
    echo "DB_USERNAME=${var.db_username}" >> .env
    echo "DB_PASSWORD=${var.db_password}" >> .env
    echo "DB_NAME=${var.db_name}" >> .env
    echo "DB_DIALECT=${var.dialect}" >> .env
    echo "PORT=${var.app_port}" >> .env
    echo "AWS_ACCESS_KEY_ID=${var.aws_access_key}" >> .env
    echo "AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}" >> .env
    echo "AWS_REGION=${var.aws_region}" >> .env
    echo "S3_BUCKET_NAME=${aws_s3_bucket.csye6225_bucket.bucket}" >> .env

    chmod 600 .env
    chown -R csye6225:csye6225 .env

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c file:/opt/cloudwatch-agent.json \
        -s
  EOF
}