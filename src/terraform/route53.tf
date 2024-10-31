resource "aws_route53_zone" "zone" {
  name = var.subdomain
}

# Create an A record for the webapp
resource "aws_route53_record" "webapp_a_record" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.subdomain
  type    = "A"
  ttl     = 60
  records = [aws_instance.webapp.public_ip] # EC2 instance public IP
}