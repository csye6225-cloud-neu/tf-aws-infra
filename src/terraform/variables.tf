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