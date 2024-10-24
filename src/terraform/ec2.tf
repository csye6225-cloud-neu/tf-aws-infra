resource "aws_instance" "webapp" {
  ami                         = var.ami_id
  key_name                    = var.ami_key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = values(aws_subnet.public_subnets)[0].id
  associate_public_ip_address = true
  instance_type               = "t2.micro"

  root_block_device {
    volume_size           = var.ec2_volume_size
    volume_type           = var.ec2_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = "webapp-instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    ####################################################
    # Create .env file for environment variables       #
    ####################################################
    cd /opt/webapp
    touch .env
    echo "DB_HOST=$(echo ${aws_db_instance.rds_instance.endpoint} | cut -d':' -f1)" >> .env
    echo "DB_USERNAME=${var.db_username}" >> .env
    echo "DB_PASSWORD=${var.db_password}" >> .env
    echo "DB_NAME=${var.db_name}" >> .env
    echo "DB_DIALECT=${var.dialect}" >> .env
    echo "PORT=${var.app_port}" >> .env

    chmod 600 .env
    chown -R csye6225:csye6225 .env
  EOF
}