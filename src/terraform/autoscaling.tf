resource "aws_launch_template" "csye6225_asg" {
  name          = "csye6225_asg"
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
    sudo touch .env
    sudo echo "DB_HOST=$(echo ${aws_db_instance.rds_instance.endpoint} | cut -d':' -f1)" >> .env
    sudo echo "DB_USERNAME=${var.db_username}" >> .env
    sudo echo "DB_PASSWORD=${var.db_password}" >> .env
    sudo echo "DB_NAME=${var.db_name}" >> .env
    sudo echo "DB_DIALECT=${var.dialect}" >> .env
    sudo echo "PORT=${var.app_port}" >> .env
    sudo echo "AWS_ACCESS_KEY_ID=${var.aws_access_key}" >> .env
    sudo echo "AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}" >> .env
    sudo echo "AWS_REGION=${var.aws_region}" >> .env
    sudo echo "S3_BUCKET_NAME=${aws_s3_bucket.csye6225_bucket.bucket}" >> .env

    sudo chmod 600 .env
    sudo chown -R csye6225:csye6225 .env

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

resource "aws_autoscaling_group" "csye6225_asg" {
  name                = "csye6225_asg"
  desired_capacity    = 3
  min_size            = 3
  max_size            = 5
  default_cooldown    = 60
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]

  launch_template {
    id      = aws_launch_template.csye6225_asg.id
    version = "$Latest"
  }

  tag {
    key                 = "Application Auto Scaling"
    value               = "csye6225_asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_policy" {
  name                   = "cpu_target_policy"
  autoscaling_group_name = aws_autoscaling_group.csye6225_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 4 # Average between 3% and 5%
  }
}