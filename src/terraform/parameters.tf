resource "aws_db_parameter_group" "rds_param_group" {
  name   = "csye6225-param-group"
  family = "mysql8.0"

  parameter {
    name  = "max_connections"
    value = "100"
  }
}