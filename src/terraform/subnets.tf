# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each        = zipmap(var.public_subnets_cidrs, var.availability_zones)
  ipv6_cidr_block = cidrsubnet(aws_vpc.csye6225_vpc.ipv6_cidr_block, 8, index(var.public_subnets_cidrs, each.key))

  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = each.key
  availability_zone = each.value

  map_public_ip_on_launch = true

  tags = {
    Name = "csye6225-public-subnet-${each.value}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each = zipmap(var.private_subnets_cidrs, var.availability_zones)

  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = each.key
  availability_zone = each.value

  map_public_ip_on_launch = false

  tags = {
    Name = "csye6225-private-subnet-${each.value}"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "csye6225-rds-subnet-group"
  subnet_ids = values(aws_subnet.private_subnets)[*].id

  tags = {
    Name = "csye6225-rds-subnet-group"
  }
}