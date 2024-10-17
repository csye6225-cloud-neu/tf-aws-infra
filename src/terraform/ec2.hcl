resource "aws_instance" "webapp" {
  ami                         = var.ami_id
  key_name                    = var.ami_key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.ec2_volume_size
    volume_type           = var.ec2_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = "webapp-instance"
  }
}