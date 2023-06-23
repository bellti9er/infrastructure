provider "aws" {
  region = "ap-northeast-2"

  # Terraform by default looks at the ~/.aws/credentials file 
  # for the aws access key and secret.
  # The profile config tells which profile credential
  # to look at in the aws credential file.
  profile = "bellti9er"
}

data "terraform_remote_state" "management" {
  backend = "s3"
  config  = {
    bucket = "bellti9er-tf-state-prod"
    key    = "management/vpc.state"
    region = "ap-northeast-2"
  }
}

############################################################
## Staging
############################################################
resource "aws_vpc" "staging" {
  cidr_block           = "11.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Staging"
  }
}

############################################################
# Public Subnets
############################################################
resource "aws_subnet" "staging_public_subnet_1" {
  vpc_id            = aws_vpc.staging.id
  cidr_block        = "11.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Staging Public Subnet 1"
  }
}

resource "aws_subnet" "staging_public_subnet_2" {
  vpc_id            = aws_vpc.staging.id
  cidr_block        = "11.0.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Staging Public Subnet 2"
  }
}

############################################################
# Private Subnets
############################################################
resource "aws_subnet" "staging_private_subnet_1" {
  vpc_id            = aws_vpc.staging.id
  cidr_block        = "11.0.4.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Staging Private Subnet 1"
  }
}

resource "aws_subnet" "staging_private_subnet_2" {
  vpc_id            = aws_vpc.staging.id
  cidr_block        = "11.0.6.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Staging Private Subnet 2"
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
  vpc_id = aws_vpc.staging.id

  tags = {
    Name = "Staging Internet Gateway"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.staging.default_route_table_id

  tags = {
    Name = "Staging Public Default Route Table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_vpc.staging.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.staging_public_subnet_1.id
  route_table_id = aws_vpc.staging.default_route_table_id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.staging_public_subnet_2.id
  route_table_id = aws_vpc.staging.default_route_table_id
}

############################################################
# Routing table for private subnets
############################################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.staging_public_subnet_1.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.staging.id

  tags = {
    Name = "Staging Private Route Table"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.staging_private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.staging_private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

############################################################
## VPC Peerings
############################################################
data "aws_caller_identity" "current" { }

resource "aws_vpc_peering_connection" "management_to_staging" {
  vpc_id        = data.terraform_remote_state.management.outputs.vpc_id
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = aws_vpc.staging.id
  auto_accept   = true
}

############################################################
# Route from the primary vpc to the secondary vpc
############################################################
resource "aws_route" "primary_vpc_public_to_secondary_vpc" {
  route_table_id            = data.terraform_remote_state.management.outputs.public_route_table_id
  destination_cidr_block    = aws_vpc.staging.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.management_to_staging.id
}

resource "aws_route" "primary_vpc_private_to_secondary_vpc" {
  route_table_id            = data.terraform_remote_state.management.outputs.private_route_table_id
  destination_cidr_block    = aws_vpc.staging.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.management_to_staging.id
}

############################################################
# Route from the secondary vpc to the primary vpc
############################################################
resource "aws_route" "secondary_vpc_public_to_primary_vpc" {
  route_table_id            = aws_default_route_table.default.id
  destination_cidr_block    = data.terraform_remote_state.management.outputs.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.management_to_staging.id
}

resource "aws_route" "secondary_vpc_private_to_primary_vpc" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.terraform_remote_state.management.outputs.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.management_to_staging.id
}