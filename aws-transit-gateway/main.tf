locals {
  # List of maps with key and route values
  vpc_attachments_with_routes = chunklist(flatten([
    for k, v in var.vpc_attachments : setproduct([{ key = k }], v.tgw_routes) if can(v.tgw_routes)
  ]), 2)

  tgw_default_route_table_tags_merged = merge(
    var.tags,
    { Name = var.name },
    var.tgw_default_route_table_tags,
  )
  # List of cidr
  vpc_route_table_destination_cidrs = flatten([
    for k,v in var.vpc_attachments : [
      for cidr in try(v.vpc_cidrs, []) : {
          cidr = cidr
      }
    ]
  ])
  # List of route tables
  vpc_route_table_id = flatten([
    for k, v in var.vpc_attachments : [
      for rtb_id in try(v.vpc_route_table_ids, []) : {
        rtb_id = rtb_id
      }
    ]
  ])
  #List of maps of subnet route information.
  vpc_routes = flatten([
    for rtb_id in local.vpc_route_table_id : [
      for cidr in local.vpc_route_table_destination_cidrs : {
        route_cidr = cidr 
        route_rtb_id = rtb_id
      }
    ]
  ])
}

################################################################################
# Transit Gateway
################################################################################

resource "aws_ec2_transit_gateway" "this" {
  count = var.create_tgw ? 1 : 0

  description                     = coalesce(var.description, var.name)
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.enable_default_route_table_propagation ? "enable" : "disable"
  auto_accept_shared_attachments  = var.enable_auto_accept_shared_attachments ? "enable" : "disable"
  multicast_support               = var.enable_multicast_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  tags = merge(
    var.tags,
    { Name = var.name },
    var.tgw_tags,
  )
}

resource "aws_ec2_tag" "this" {
  for_each = { for k, v in local.tgw_default_route_table_tags_merged : k => v if var.create_tgw && var.enable_default_route_table_association }

  resource_id = aws_ec2_transit_gateway.this[0].association_default_route_table_id
  key         = each.key
  value       = each.value
}

################################################################################
# VPC Attachment
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = var.create_tgw ? aws_ec2_transit_gateway.this[0].id : each.value.tgw_id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  dns_support                                     = try(each.value.dns_support, true) ? "enable" : "disable"
  ipv6_support                                    = try(each.value.ipv6_support, false) ? "enable" : "disable"
  appliance_mode_support                          = try(each.value.appliance_mode_support, false) ? "enable" : "disable"
  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, true)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, true)

  tags = merge(
    var.tags,
    { Name = var.name },
    var.tgw_vpc_attachment_tags,
    try(each.value.tags, {}),
  )
}

################################################################################
# Route Table / Routes
################################################################################

resource "aws_ec2_transit_gateway_route_table" "this" {
  count = var.create_tgw ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.this[0].id

  tags = merge(
    var.tags,
    { Name = var.name },
    var.tgw_route_table_tags,
  )
}

resource "aws_ec2_transit_gateway_route" "this" {
  count = var.cross_account_assosiation_propagation == false ? length(local.vpc_attachments_with_routes) : 0 

  destination_cidr_block = local.vpc_attachments_with_routes[count.index][1].destination_cidr_block
  blackhole              = try(local.vpc_attachments_with_routes[count.index][1].blackhole, null)

  transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = tobool(try(local.vpc_attachments_with_routes[count.index][1].blackhole, false)) == false ? aws_ec2_transit_gateway_vpc_attachment.this[local.vpc_attachments_with_routes[count.index][0].key].id : null
}

# Cross account resource
resource "aws_ec2_transit_gateway_route" "network_account" {
  provider = aws.network_account
  count = var.cross_account_assosiation_propagation == true ? length(local.vpc_attachments_with_routes) : 0 

  
  destination_cidr_block = local.vpc_attachments_with_routes[count.index][1].destination_cidr_block
  blackhole              = try(local.vpc_attachments_with_routes[count.index][1].blackhole, null)

  transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = tobool(try(local.vpc_attachments_with_routes[count.index][1].blackhole, false)) == false ? aws_ec2_transit_gateway_vpc_attachment.this[local.vpc_attachments_with_routes[count.index][0].key].id : null
}

resource "aws_route" "this" {
  for_each = { for routes  in local.vpc_routes : "${routes.route_rtb_id.rtb_id}.${routes.route_cidr.cidr}" => routes }

  route_table_id         = each.value.route_rtb_id.rtb_id
  destination_cidr_block = each.value.route_cidr.cidr
  transit_gateway_id     = var.create_tgw ? aws_ec2_transit_gateway.this[0].id : join (",", [for k, v in var.vpc_attachments : v.tgw_id])
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = {
    for k, v in var.vpc_attachments : k => v if try(v.transit_gateway_default_route_table_association, true) != true && v.cross_account_assosiation_propagation == false
  }

  # Create association if it was not set already by aws_ec2_transit_gateway_vpc_attachment resource
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : try(each.value.transit_gateway_route_table_id, var.transit_gateway_route_table_id)
}

# Cross account resource
# resource "aws_ec2_transit_gateway_route_table_association" "network_account" {
#   provider = aws.network_account
#   for_each = {
#     for k, v in var.vpc_attachments : k => v if try(v.transit_gateway_default_route_table_association, true) != true && v.cross_account_assosiation_propagation == true
#   }

#   # Create association if it was not set already by aws_ec2_transit_gateway_vpc_attachment resource
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
#   transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : try(each.value.transit_gateway_route_table_id, var.transit_gateway_route_table_id)
# }

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = {
    for k, v in var.vpc_attachments : k => v if try(v.transit_gateway_default_route_table_propagation, true) != true && v.cross_account_assosiation_propagation == false
  }

  # Create association if it was not set already by aws_ec2_transit_gateway_vpc_attachment resource
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : try(each.value.transit_gateway_route_table_id, var.transit_gateway_route_table_id)
}

## Cross account resource
# resource "aws_ec2_transit_gateway_route_table_propagation" "network_account" {
#   provider = aws.network_account
#   for_each = {
#     for k, v in var.vpc_attachments : k => v if try(v.transit_gateway_default_route_table_propagation, true) != true && v.cross_account_assosiation_propagation == true
#   }

#   # Create association if it was not set already by aws_ec2_transit_gateway_vpc_attachment resource
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
#   transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : try(each.value.transit_gateway_route_table_id, var.transit_gateway_route_table_id)
# }

################################################################################
# Resource Access Manager
################################################################################

resource "aws_ram_resource_share" "this" {
  count = var.create_tgw && var.share_tgw ? 1 : 0

  name                      = coalesce(var.ram_name, var.name)
  allow_external_principals = var.ram_allow_external_principals

  tags = merge(
    var.tags,
    { Name = coalesce(var.ram_name, var.name) },
    var.ram_tags,
  )
}

resource "aws_ram_resource_association" "this" {
  count = var.create_tgw && var.share_tgw ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.this[0].arn
  resource_share_arn = aws_ram_resource_share.this[0].id
}

resource "aws_ram_principal_association" "this" {
  count = var.create_tgw && var.share_tgw ? length(var.ram_principals) : 0

  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_resource_share_accepter" "this" {
  count = !var.create_tgw && var.share_tgw ? 1 : 0

  share_arn = var.ram_resource_share_arn
}
