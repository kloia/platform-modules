output "vpc_peering_id" {
    description = "ID of the vpc peering"
    value = aws_vpc_peering_connection.peer.id
}

output "requester_vpc_id" {
  description = "ID of the requester vpc"
  value = var.requester_vpc_id
}

output "accepter_vpc_id" {
  description = "ID of the accepter vpc"
  value = var.accepter_vpc_id
}

output "requester_vpc_cidr_block" {
  description = "VPC CIDR block of the requester vpc"
  value = var.requester_vpc_cidr_block
} 

output "accepter_private_route_table_ids" {
  description = "Private route table IDs of the accepter vpc"
  value = var.accepter_private_route_table_ids
} 

output "accepter_public_route_table_ids" {
  description = "Public route table IDs of the accepter vpc"
  value = var.accepter_public_route_table_ids
} 