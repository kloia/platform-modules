

resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.vpc_peer_id != "" ? 1 : 0
  vpc_peering_connection_id = var.vpc_peer_id
  auto_accept               = true

  tags = merge(var.tags, {
    Name = var.name
    Side = "Accepter"
  })

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}


resource "aws_vpc_peering_connection_accepter" "batch_peer" {
  count                     = length(var.vpc_peer_ids) > 0 ? length(var.vpc_peer_ids) : 0
  vpc_peering_connection_id = var.vpc_peer_ids[count.index]
  auto_accept               = true

  tags = merge(var.tags, {
    Name = var.name
    Side = "Accepter"
  })

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}
