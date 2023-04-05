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

output "accepter_database_route_table_ids" {
  description = "Database route table IDs of the accepter vpc"
  value = var.accepter_database_route_table_ids
} 
output "accepter_eks_route_table_ids" {
  description = "EKS route table IDs of the accepter vpc"
  value = var.accepter_eks_route_table_ids
} 

output "accepter_mq_route_table_ids" {
  description = "MQ route table IDs of the accepter vpc"
  value = var.accepter_mq_route_table_ids
} 


output "accepter_ecs_route_table_ids" {
  description = "ECS route table IDs of the accepter vpc"
  value = var.accepter_ecs_route_table_ids
} 


output "accepter_cache_route_table_ids" {
  description = "Cache route table IDs of the accepter vpc"
  value = var.accepter_cache_route_table_ids
} 
output "accepter_private_route_table_ids" {
  description = "Private route table IDs of the accepter vpc"
  value = var.accepter_private_route_table_ids
} 

output "accepter_public_route_table_ids" {
  description = "Public route table IDs of the accepter vpc"
  value = var.accepter_public_route_table_ids
} 