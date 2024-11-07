data "aws_route53_zone" "zone" {
  name = var.subdomain
}

# Create an A record for the load balancer
resource "aws_route53_record" "lb_a_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.subdomain
  type    = "A"
  alias {
    name                   = aws_lb.csye6225_lb.dns_name
    zone_id                = aws_lb.csye6225_lb.zone_id
    evaluate_target_health = true
  }
}