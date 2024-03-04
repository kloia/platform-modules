resource "aws_vpc_peering_connection" "peer" {
    count = var.create_cross_account_peering ? 0 : 1

    peer_owner_id = var.peer_owner_account_id #requester account id
    peer_vpc_id = var.accepter_vpc_id #accepter vpc id
    vpc_id = var.requester_vpc_id #requester vpc id
    peer_region = var.peer_region
    auto_accept = false

    tags = {
        Name = "aws peering - requester"
    }
}





### Cross account requester resources 


# Upstream account values
# data "aws_ssm_parameter" "requester_private_route_table_ids" {
#   count = var.fetch_from_ssm && var.create_cross_account_peering ? 1 : 0
#   provider = aws.shared_infra
#   name = var.requester_private_route_table_ids_key
# }

# data "aws_ssm_parameter" "requester_public_route_table_ids" {
#   count = var.fetch_from_ssm && var.create_cross_account_peering ? 1 : 0
#   provider = aws.shared_infra
#   name = var.requester_public_route_table_ids_key
# }

# data "aws_ssm_parameter" "requester_vpc_cidr_block" {
#   count = var.fetch_from_ssm && var.create_cross_account_peering ? 1 : 0
#   provider = aws.shared_infra
#   name = var.requester_vpc_cidr_block_key
# }

# data "aws_ssm_parameter" "requester_vpc_id" {
#   count = var.fetch_from_ssm && var.create_cross_account_peering ? 1 : 0
#   provider = aws.shared_infra
#   name = var.requester_vpc_id_key
# }




# VPC Peering Connection Options

resource "aws_vpc_peering_connection" "cross_peer" {
    provider = aws.shared_infra
    count = var.create_cross_account_peering ? 1 : 0

    vpc_id = var.requester_vpc_id #requester vpc id
    peer_vpc_id = var.accepter_vpc_id #accepter vpc id
    peer_owner_id = var.peer_owner_account_id #accepter account id
    peer_region = var.peer_region
    auto_accept = false

    tags = {
        Name = "aws peering - requester"
    }

}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "cross_accepter" {
  count = var.create_cross_account_peering ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.cross_peer[0].id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}




resource "aws_vpc_peering_connection_options" "cross_peer" {
  count = var.create_cross_account_peering ? 1 : 0

  provider = aws.shared_infra

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.cross_accepter[0].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "cross_accepter" {
  count = var.create_cross_account_peering ? 1 : 0


  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.cross_accepter[0].id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}


