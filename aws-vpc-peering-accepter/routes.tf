
resource "aws_route" "accepter_private_route_table_route" {
    count = length(var.accepter_private_route_table_ids) > 0 && length(var.requester_peer_info) == 0 ? length(var.accepter_private_route_table_ids) : 0
    vpc_peering_connection_id = var.vpc_peer_id
    route_table_id = var.accepter_private_route_table_ids[count.index]
    destination_cidr_block = var.requester_vpc_cidr_block

}


resource "aws_route" "accepter_public_route_table_route" {
    count = length(var.accepter_public_route_table_ids) > 0 && length(var.requester_peer_info) == 0 ? length(var.accepter_public_route_table_ids) : 0
    vpc_peering_connection_id = var.vpc_peer_id
    route_table_id = var.accepter_public_route_table_ids[count.index]
    destination_cidr_block = var.requester_vpc_cidr_block

}

# Multiple peerin acceptance with multpile route propagation.
locals {

    route_tables = length(var.accepter_private_route_table_ids) > 0 ? var.accepter_private_route_table_ids : var.accepter_public_route_table_ids
    peer_detail = var.requester_peer_info

    routes = flatten([
        for table in local.route_tables : [
            for p in local.peer_detail : {
                table_id = table
                cidr     = p.requester_cidr
                peer_id  = p.peer_id 
            }
        ]
    ]
    )
}

resource "aws_route" "accepter_table_multiple_route" {
    for_each    = {for routes in local.routes: "${routes.table_id}.${routes.peer_id}" => routes }
    vpc_peering_connection_id = each.value.peer_id
    route_table_id = each.value.table_id
    destination_cidr_block = each.value.cidr
}
