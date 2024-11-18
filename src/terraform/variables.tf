variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
}

variable "app_port" {
  description = "Port on which the application listens"
  type        = number
  default     = 8080
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ami_key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string
}

variable "ec2_volume_size" {
  description = "Size of the root volume for the EC2 instance"
  type        = number
  default     = 25
}

variable "ec2_volume_type" {
  description = "Type of the root volume for the EC2 instance"
  type        = string
  default     = "gp2"
}

variable "db_port" {
  description = "The database port"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "user"
}

variable "db_password" {
  description = "The database password for the RDS instance."
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "The allocated storage for the database (in GB)"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "csye6225"
}

variable "db_instance_class" {
  description = "The RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "dialect" {
  description = "The database dialect"
  type        = string
  default     = "mysql"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "subdomain" {
  description = "The subdomain for the Route 53 hosted zone"
  type        = string
  default     = "dev.pinkaew-cloud.me"
}

variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
}

variable "min_max_threshold" {
  description = "The threshold for the CloudWatch alarm"
  type        = list(number)
  default     = [6, 8]
}

variable "sendgrid_api_key" {
  description = "The SendGrid API key"
  type        = string
}

variable "email_from" {
  description = "The email address from which emails are sent"
  type        = string
  default     = "support@pinkaew-cloud.me"
}

variable "lambda_dir" {
  description = "The path to the ZIP file containing the Lambda function code"
  type        = string
}