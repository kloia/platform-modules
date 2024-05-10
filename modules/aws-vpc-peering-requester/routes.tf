resource "aws_route" "requester_private_route_table_route" {
  count                     = var.create_cross_account_peering ? 0 : 1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
  route_table_id            = var.requester_private_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr_block

}


resource "aws_route" "requester_public_route_table_route" {
  count                     = var.create_cross_account_peering ? 0 : 1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
  route_table_id            = var.requester_public_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr_block

}



# Cross Account Route Resources
# Upstream (Requester Account) Routes
locals {
  private_route_table_ids = var.create_cross_account_peering ? var.requester_private_route_table_ids : null

  public_route_table_ids = var.create_cross_account_peering ? var.requester_public_route_table_ids : null
}


resource "aws_route" "cross_account_requester_private_route_table_route" {
  provider                  = aws.shared_infra
  count                     = var.create_cross_account_peering ? length(local.private_route_table_ids) : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.cross_peer[0].id
  route_table_id            = local.private_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr_block

}


resource "aws_route" "cross_account_requester_public_route_table_route" {
  provider                  = aws.shared_infra
  count                     = var.create_cross_account_peering ? length(local.public_route_table_ids) : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.cross_peer[0].id
  route_table_id            = local.public_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_vpc_cidr_block

}

# # Downstream (Accepter Account) Routes
resource "aws_route" "cross_account_accepter_private_route_table_route" {
  count                     = length(var.accepter_private_route_table_ids) > 0 && var.create_cross_account_peering ? length(var.accepter_private_route_table_ids) : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.cross_peer[0].id
  route_table_id            = var.accepter_private_route_table_ids[count.index]
  destination_cidr_block    = var.requester_vpc_cidr_block

}


resource "aws_route" "cross_account_accepter_public_route_table_route" {
  count                     = length(var.accepter_public_route_table_ids) > 0 && var.create_cross_account_peering ? length(var.accepter_public_route_table_ids) : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.cross_peer[0].id
  route_table_id            = var.accepter_public_route_table_ids[count.index]
  destination_cidr_block    = var.requester_vpc_cidr_block

}



