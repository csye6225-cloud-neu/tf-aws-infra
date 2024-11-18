resource "aws_autoscaling_group" "csye6225_asg" {
  name                = "csye6225_asg"
  desired_capacity    = 3
  min_size            = 3
  max_size            = 5
  default_cooldown    = 60
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]

  launch_template {
    id      = aws_launch_template.csye6225_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Application Auto Scaling"
    value               = "csye6225_asg"
    propagate_at_launch = true
  }
}

# Scale-up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.csye6225_asg.name
}

# Scale-down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.csye6225_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300 # Check every 5 minute
  statistic           = "Average"
  namespace           = "AWS/EC2"
  threshold           = var.min_max_threshold[1]
  alarm_description   = "Alarm when CPU usage is greater than ${var.min_max_threshold[1]}%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.csye6225_asg.name
  }
  tags = {
    Name = "scale-up-cpu-usage"
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale-down-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300 # Check every 5 minute
  statistic           = "Average"
  namespace           = "AWS/EC2"
  threshold           = var.min_max_threshold[0]
  alarm_description   = "Alarm when CPU usage is less than ${var.min_max_threshold[0]}%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.csye6225_asg.name
  }
  tags = {
    Name = "scale-down-cpu-usage"
  }
}