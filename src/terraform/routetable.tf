# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.csye6225_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "csye6225-public-route-table"
  }
}

# Attach public subnets to the public route table
resource "aws_route_table_association" "public_subnets_assoc" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}


# Private Route Table (without internet access)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "csye6225-private-route-table"
  }
}

# Attach private subnets to the private route table
resource "aws_route_table_association" "private_subnets_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}