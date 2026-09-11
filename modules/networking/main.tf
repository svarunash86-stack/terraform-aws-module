locals {
  project_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(
    local.project_tags,
    {
      Name = "${local.project_tags.Name}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${local.project_tags.Name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "web_subnet" {
  for_each = var.public_subnets

  vpc_id = aws_vpc.my_vpc.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  # Web instances need public IPs
  map_public_ip_on_launch = true

  tags = {
    Name       = "${local.project_tags.Name}-${each.key}"
    SubnetType = each.value.subnet_type
  }
}

# Private Subnets
resource "aws_subnet" "db_subnet" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.my_vpc.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name       = "${local.project_tags.Name}-${each.key}"
    SubnetType = each.value.subnet_type
  }
}

# Public Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.project_tags.Name}-public-rtb"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public_rtb_association" {
  for_each = aws_subnet.web_subnet

  subnet_id = each.value.id

  route_table_id = aws_route_table.public_rtb.id
}

# Private Route Table
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${local.project_tags.Name}-private-rtb"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "private_rtb_association" {
  for_each = aws_subnet.db_subnet

  subnet_id = each.value.id

  route_table_id = aws_route_table.private_rtb.id
}