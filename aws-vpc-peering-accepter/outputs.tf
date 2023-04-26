output "vpc_peering_id" {
    description = "ID of the vpc peering"
    value = var.vpc_peer_id
}

output "requester_vpc_cidr_block" {
  description = "The CIDR Block of the requester VPC"
  value = var.requester_vpc_cidr_block
}

output "accepter_private_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"  
  value = var.accepter_private_route_table_ids
}

output "accepter_public_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  value = var.accepter_public_route_table_ids
}