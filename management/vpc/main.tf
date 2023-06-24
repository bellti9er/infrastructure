provider "aws" {
  region = "ap-northeast-2"
  
  # Terraform by default looks at the ~/.aws/credentials file 
  # for the aws access key and secret.
  # The profile config tells which profile credential
  # to look at in the aws credential file.
  profile = "bellti9er"
}

############################################################
# Management
############################################################
resource "aws_vpc" "management" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Management"
  }
}

############################################################
# Public Subnets
############################################################
resource "aws_subnet" "management_public_subnet_1" {
  vpc_id            = aws_vpc.management.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Management Public Subnet 1"
  }
}

resource "aws_subnet" "management_public_subnet_2" {
  vpc_id            = aws_vpc.management.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Management Public Subnet 2"
  }
}

############################################################
# Private Subnets
############################################################
resource "aws_subnet" "management_private_subnet_1" {
  vpc_id            = aws_vpc.management.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Management Private Subnet 1"
  }
}

resource "aws_subnet" "management_private_subnet_2" {
  vpc_id            = aws_vpc.management.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Management Private Subnet 2"
  }
}

############################################################
# EIP
############################################################
resource "aws_eip" "nat" {
  domain = "vpc"
}

############################################################
# Routing table for public subnets
############################################################
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.management.id

  tags = {
    Name = "Management Internet Gateway"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.management.default_route_table_id

  tags = {
    Name = "Management Public Default Route Table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_vpc.management.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.management_public_subnet_1.id
  route_table_id = aws_vpc.management.default_route_table_id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.management_public_subnet_2.id
  route_table_id = aws_vpc.management.default_route_table_id
}

############################################################
# Routing table for private subnets
############################################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.management_public_subnet_1.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.management.id

  tags = {
    Name = "Management Private Route Table"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.management_private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.management_private_subnet_2.id
  route_table_id = aws_route_table.private.id
}
