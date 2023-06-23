############################################################
## VPC
############################################################
output "vpc_id" {
  value = aws_vpc.management.id
}

output "vpc_cidr_block" {
  value = aws_vpc.management.cidr_block
}

output "public_subnet_ids" {
  value = [
    aws_subnet.management_public_subnet_1.id,
    aws_subnet.management_public_subnet_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.management_private_subnet_1.id,
    aws_subnet.management_private_subnet_2.id
  ]
}

output "public_route_table_id" {
  value = aws_vpc.management.default_route_table_id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_subnet_az_to_id_map" {
  value = {
    for subnet in [
      aws_subnet.management_public_subnet_1,
      aws_subnet.management_public_subnet_2
    ] : subnet.availability_zone => subnet.id
  }
}

output "private_subnet_az_to_id_map" {
  value = {
    for subnet in [
      aws_subnet.management_private_subnet_1,
      aws_subnet.management_private_subnet_2
    ] : subnet.availability_zone => subnet.id
  }
}