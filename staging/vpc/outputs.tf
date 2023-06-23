############################################################
## VPC
############################################################
output "vpc_id" {
  value = aws_vpc.staging.id
}

output "vpc_cidr_block" {
  value = aws_vpc.staging.cidr_block
}

output "public_subnet_ids" {
  value = [
    aws_subnet.staging_public_subnet_1.id,
    aws_subnet.staging_public_subnet_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.staging_private_subnet_1.id,
    aws_subnet.staging_private_subnet_2.id
  ]
}

output "public_route_table_id" {
  value = aws_vpc.staging.default_route_table_id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_subnet_az_to_id_map" {
  value = {
    for subnet in [
      aws_subnet.staging_public_subnet_1,
      aws_subnet.staging_public_subnet_2
    ] : subnet.availability_zone => subnet.id
  }
}

output "private_subnet_az_to_id_map" {
  value = {
    for subnet in [
      aws_subnet.staging_private_subnet_1,
      aws_subnet.staging_private_subnet_2
    ] : subnet.availability_zone => subnet.id
  }
}

############################################################
## VPC Peering
############################################################
output "vpc_peering_id" { 
  value = aws_vpc_peering_connection.management_to_staging.id
}

output "vpc_peering_accept_status" { 
  value = aws_vpc_peering_connection.management_to_staging.accept_status
}
