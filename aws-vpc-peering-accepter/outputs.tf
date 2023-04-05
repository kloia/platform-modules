output "vpc_peering_id" {
    description = "ID of the vpc peering"
    value = var.vpc_peer_id
}


output "accepter_eks_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  value = var.accepter_eks_route_table_ids
}

output "accepter_ecs_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  value = var.accepter_ecs_route_table_ids
}

output "accepter_mq_route_table_ids" {
  description = "The mq route table IDs of accepter VPC route tables"
  value = var.accepter_mq_route_table_ids
}

output "accepter_database_route_table_ids" {
  description = "The database route table IDs of accepter VPC route tables"
  value = var.accepter_database_route_table_ids
}
output "requester_vpc_cidr_block" {
  description = "The CIDR Block of the requester VPC"
  value = var.requester_vpc_cidr_block
}

output "accepter_cache_route_table_ids" {
  description = "The cache route table IDs of accepter VPC route tables"
  value = var.accepter_cache_route_table_ids
  }
output "accepter_private_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"  
  value = var.accepter_private_route_table_ids
}

output "accepter_public_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  value = var.accepter_public_route_table_ids
}