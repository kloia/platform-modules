resource "aws_vpc_peering_connection" "peer" {
    peer_owner_id = var.peer_owner_account_id #requester account id
    peer_vpc_id = var.accepter_vpc_id #accepter vpc id
    vpc_id = var.requester_vpc_id #requester vpc id
    peer_region = var.peer_region
    auto_accept = false

    tags = {
        Name = "aws peering - requester"
    }
}