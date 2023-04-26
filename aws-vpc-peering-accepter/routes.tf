
resource "aws_route" "accepter_private_route_table_route" {
    count = length(var.accepter_private_route_table_ids) > 0 ? length(var.accepter_private_route_table_ids) : 0
    vpc_peering_connection_id = var.vpc_peer_id
    route_table_id = var.accepter_private_route_table_ids[count.index]
    destination_cidr_block = var.requester_vpc_cidr_block

}


resource "aws_route" "accepter_public_route_table_route" {
    count = length(var.accepter_public_route_table_ids) > 0 ? length(var.accepter_public_route_table_ids) : 0
    vpc_peering_connection_id = var.vpc_peer_id
    route_table_id = var.accepter_public_route_table_ids[count.index]
    destination_cidr_block = var.requester_vpc_cidr_block

}

