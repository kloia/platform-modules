resource "aws_route" "requester_database_route_table_route" {
    count = length(var.requester_database_route_table_ids) > 0 ? length(var.requester_database_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_database_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}


resource "aws_route" "requester_mq_route_table_route" {
    count = length(var.requester_mq_route_table_ids) > 0 ? length(var.requester_mq_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_mq_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}

resource "aws_route" "requester_ecs_route_table_route" {
    count = length(var.requester_ecs_route_table_ids) > 0 ? length(var.requester_ecs_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_ecs_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}


resource "aws_route" "requester_eks_route_table_route" {
    count = length(var.requester_eks_route_table_ids) > 0 ? length(var.requester_eks_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_eks_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}


resource "aws_route" "requester_cache_route_table_route" {
    count = length(var.requester_cache_route_table_ids) > 0 ? length(var.requester_cache_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_cache_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}

resource "aws_route" "requester_private_route_table_route" {
    count = length(var.requester_private_route_table_ids) > 0 ? length(var.requester_private_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_private_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}


resource "aws_route" "requester_public_route_table_route" {
    count = length(var.requester_public_route_table_ids) > 0 ? length(var.requester_public_route_table_ids) : 0
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = var.requester_public_route_table_ids[count.index]
    destination_cidr_block = var.accepter_vpc_cidr_block

}
