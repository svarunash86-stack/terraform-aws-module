locals {
  project_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------
# ALB Security Group
# --------------------------------------------------

resource "aws_security_group" "alb_sg" {

  name = "${local.project_tags.Name}-alb-sg"

  description = "Security group for Application Load Balancer"

  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from Internet"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS from Internet"

    from_port = 443
    to_port   = 443

    protocol = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.project_tags.Name}-alb-sg"
  }
}

# --------------------------------------------------
# Web Server Security Group
# --------------------------------------------------

resource "aws_security_group" "web_sg" {

  name = "${local.project_tags.Name}-web-sg"

  description = "Security group for web servers"

  vpc_id = var.vpc_id

  # HTTP will be added using a separate SG rule
  # from the ALB security group.

  dynamic "ingress" {
    for_each = var.ssh_cidr_blocks

    content {
      description = "SSH"

      from_port = 22
      to_port   = 22

      protocol = "tcp"

      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.project_tags.Name}-web-sg"
  }
}

# Allow ALB to communicate with Web Servers
resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {

  security_group_id = aws_security_group.web_sg.id

  referenced_security_group_id = aws_security_group.alb_sg.id

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"

  description = "HTTP from Application Load Balancer"
}