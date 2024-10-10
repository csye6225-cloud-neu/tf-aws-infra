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