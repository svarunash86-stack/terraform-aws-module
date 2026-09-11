variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to EC2"
  type        = list(string)

  default = []
}