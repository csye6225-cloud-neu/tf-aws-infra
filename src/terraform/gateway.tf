resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "csye6225_gateway"
  }
}