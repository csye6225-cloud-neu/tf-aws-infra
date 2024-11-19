resource "aws_vpc" "csye6225_vpc" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "csye6225_vpc"
  }
}