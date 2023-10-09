locals {
  enabled                    = var.enabled
  mutual_enabled             = local.enabled && var.authentication_type == "certificate-authentication"
  logging_enabled            = local.enabled && var.logging_enabled
  root_certificate_chain_arn = local.mutual_enabled ? var.root_cert_arn : null
  cloudwatch_log_group       = local.logging_enabled ? var.log_group_name : null
  additional_routes_for_all_subnets = length(var.additional_routes_for_all) > 0 ? flatten([
    for route in var.additional_routes_for_all : [
      for subnet in var.associated_subnets :
      {
        "destination_cidr_block" = route.destination_cidr_block
        "description"            = route.description
        "target_vpc_subnet_id"   = subnet
      }
    ]
  ]) : []
  additional_routes = concat(var.additional_routes, local.additional_routes_for_all_subnets)
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  count = local.enabled ? 1 : 0

  server_certificate_arn = var.server_cert_arn
  client_cidr_block      = var.client_cidr
  transport_protocol     = var.transport_protocol

  authentication_options {
    type                       = var.authentication_type
    saml_provider_arn          = var.saml_provider_arn
    root_certificate_chain_arn = local.root_certificate_chain_arn
  }

  connection_log_options {
    enabled              = var.logging_enabled
    cloudwatch_log_group = local.cloudwatch_log_group
  }

  dns_servers  = var.dns_servers
  split_tunnel = var.split_tunnel

  session_timeout_hours = var.session_timeout_hours

  security_group_ids = [var.security_group_id]
  vpc_id             = var.vpc_id
  tags               = var.tags
}

resource "aws_ec2_client_vpn_network_association" "default" {
  count = local.enabled ? length(var.associated_subnets) : 0

  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default[*].id)
  subnet_id              = var.associated_subnets[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "default" {
  count = local.enabled ? length(var.authorization_rules) : 0

  access_group_id        = lookup(var.authorization_rules[count.index], "access_group_id", null)
  authorize_all_groups   = lookup(var.authorization_rules[count.index], "authorize_all_groups", null)
  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default[*].id)
  description            = var.authorization_rules[count.index].description
  target_network_cidr    = var.authorization_rules[count.index].target_network_cidr
}

resource "aws_ec2_client_vpn_route" "default" {
  count = local.enabled ? length(local.additional_routes) : 0

  description            = try(local.additional_routes[count.index].description, null)
  destination_cidr_block = local.additional_routes[count.index].destination_cidr_block
  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default[*].id)
  target_vpc_subnet_id   = local.additional_routes[count.index].target_vpc_subnet_id

  depends_on = [
    aws_ec2_client_vpn_network_association.default
  ]

  timeouts {
    create = "5m"
    delete = "5m"
  }
}
