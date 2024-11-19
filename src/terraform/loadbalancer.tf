resource "aws_lb" "csye6225_lb" {
  name                       = "csye6225-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = [for subnet in aws_subnet.public_subnets : subnet.id]
  enable_deletion_protection = false
  ip_address_type            = "dualstack" # Enable IPv4 and IPv6

  tags = {
    Name = "csye6225-lb"
  }
}

resource "aws_lb_listener" "csye6225_lb_listener" {
  load_balancer_arn = aws_lb.csye6225_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.csye6225_vpc.id

  health_check {
    path     = "/healthz"
    protocol = "HTTP"
    port     = "8080"
  }

  tags = {
    Name = "webapp-tg"
  }
}

resource "aws_autoscaling_attachment" "asg_lb" {
  autoscaling_group_name = aws_autoscaling_group.csye6225_asg.name
  lb_target_group_arn    = aws_lb_target_group.webapp_tg.arn
}