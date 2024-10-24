resource "aws_db_instance" "rds_instance" {
  identifier           = "csye6225-rds-instance"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  multi_az             = false # No multi-AZ
  allocated_storage    = var.db_allocated_storage
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.rds_param_group.name

  skip_final_snapshot = true
}