resource "aws_ec2_transit_gateway_route" "this" {
  count = length(var.peer_routes)
  destination_cidr_block         = var.peer_routes[count.index]
  transit_gateway_attachment_id  = var.peer_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  blackhole                      = var.blackhole
}