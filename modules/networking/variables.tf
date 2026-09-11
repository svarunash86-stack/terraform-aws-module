variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet configuration"

  type = map(object({
    cidr_block        = string
    availability_zone = string
    subnet_type       = string
  }))
}

variable "private_subnets" {
  description = "Private subnet configuration"

  type = map(object({
    cidr_block        = string
    availability_zone = string
    subnet_type       = string
  }))
}