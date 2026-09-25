locals {
  tunnel_options = merge({
    ike_versions                 = null
    phase1_encryption_algorithms = null
    phase1_integrity_algorithms  = null
    phase1_dh_group_numbers      = null
    phase1_lifetime_seconds      = null
    phase2_encryption_algorithms = null
    phase2_integrity_algorithms  = null
    phase2_dh_group_numbers      = null
    phase2_lifetime_seconds      = null
    dpd_timeout_action           = null
    dpd_timeout_seconds          = null
    startup_action               = null
  }, var.tunnel_options)

  log_group_arn = var.create_tunnel_log_group ? aws_cloudwatch_log_group.tunnel[0].arn : var.tunnel_log_group_arn
  log_enabled   = local.log_group_arn != null

  tunnels = {
    tunnel1 = aws_vpn_connection.this.tunnel1_address
    tunnel2 = aws_vpn_connection.this.tunnel2_address
  }
}

resource "aws_customer_gateway" "this" {
  bgp_asn     = var.customer_gateway_bgp_asn
  ip_address  = var.customer_gateway_ip_address
  device_name = var.customer_gateway_device_name
  type        = "ipsec.1"

  tags = merge(var.tags, { Name = "${var.name}-cgw" })
}

# The VPN service adds its own CloudWatch Logs resource policy for this group when logging
# is enabled, so none is declared here.
resource "aws_cloudwatch_log_group" "tunnel" {
  count = var.create_tunnel_log_group ? 1 : 0

  name              = "/aws/vendedlogs/site-to-site-vpn/${var.name}"
  retention_in_days = var.tunnel_log_retention_in_days
  kms_key_id        = var.tunnel_log_kms_key_id

  tags = var.tags
}

resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = var.static_routes_only

  local_ipv4_network_cidr  = var.local_ipv4_network_cidr
  remote_ipv4_network_cidr = var.remote_ipv4_network_cidr

  tunnel1_inside_cidr   = try(var.tunnel_inside_cidrs[0], null)
  tunnel2_inside_cidr   = try(var.tunnel_inside_cidrs[1], null)
  tunnel1_preshared_key = try(var.tunnel_preshared_keys[0], null)
  tunnel2_preshared_key = try(var.tunnel_preshared_keys[1], null)

  # Both tunnels take the same options, so the remote side configures one policy.
  tunnel1_ike_versions                 = local.tunnel_options.ike_versions
  tunnel2_ike_versions                 = local.tunnel_options.ike_versions
  tunnel1_phase1_encryption_algorithms = local.tunnel_options.phase1_encryption_algorithms
  tunnel2_phase1_encryption_algorithms = local.tunnel_options.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = local.tunnel_options.phase1_integrity_algorithms
  tunnel2_phase1_integrity_algorithms  = local.tunnel_options.phase1_integrity_algorithms
  tunnel1_phase1_dh_group_numbers      = local.tunnel_options.phase1_dh_group_numbers
  tunnel2_phase1_dh_group_numbers      = local.tunnel_options.phase1_dh_group_numbers
  tunnel1_phase1_lifetime_seconds      = local.tunnel_options.phase1_lifetime_seconds
  tunnel2_phase1_lifetime_seconds      = local.tunnel_options.phase1_lifetime_seconds
  tunnel1_phase2_encryption_algorithms = local.tunnel_options.phase2_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = local.tunnel_options.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = local.tunnel_options.phase2_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = local.tunnel_options.phase2_integrity_algorithms
  tunnel1_phase2_dh_group_numbers      = local.tunnel_options.phase2_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = local.tunnel_options.phase2_dh_group_numbers
  tunnel1_phase2_lifetime_seconds      = local.tunnel_options.phase2_lifetime_seconds
  tunnel2_phase2_lifetime_seconds      = local.tunnel_options.phase2_lifetime_seconds
  tunnel1_dpd_timeout_action           = local.tunnel_options.dpd_timeout_action
  tunnel2_dpd_timeout_action           = local.tunnel_options.dpd_timeout_action
  tunnel1_dpd_timeout_seconds          = local.tunnel_options.dpd_timeout_seconds
  tunnel2_dpd_timeout_seconds          = local.tunnel_options.dpd_timeout_seconds
  tunnel1_startup_action               = local.tunnel_options.startup_action
  tunnel2_startup_action               = local.tunnel_options.startup_action

  dynamic "tunnel1_log_options" {
    for_each = local.log_enabled ? [1] : []
    content {
      cloudwatch_log_options {
        log_enabled       = true
        log_group_arn     = local.log_group_arn
        log_output_format = "json"
      }
    }
  }

  dynamic "tunnel2_log_options" {
    for_each = local.log_enabled ? [1] : []
    content {
      cloudwatch_log_options {
        log_enabled       = true
        log_group_arn     = local.log_group_arn
        log_output_format = "json"
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-vpn" })
}

# On a transit gateway with default association/propagation enabled, AWS already associates
# the attachment with the default route table; declaring that association again fails.
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count = var.transit_gateway_route_table_association ? 1 : 0

  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  count = var.transit_gateway_route_table_propagation ? 1 : 0

  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# A static VPN propagates nothing into the transit gateway route table; the remote CIDRs
# need these routes.
resource "aws_ec2_transit_gateway_route" "remote" {
  for_each = toset(var.remote_cidrs)

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

resource "aws_cloudwatch_metric_alarm" "tunnel_state" {
  for_each = var.create_tunnel_alarms ? local.tunnels : {}

  alarm_name        = "${var.name}-${each.key}-state"
  alarm_description = "Site-to-site VPN ${var.name} (${aws_vpn_connection.this.id}): ${each.key} (${each.value}) is DOWN."

  namespace   = "AWS/VPN"
  metric_name = "TunnelState"
  statistic   = "Maximum"
  dimensions = {
    VpnId           = aws_vpn_connection.this.id
    TunnelIpAddress = each.value
  }

  # TunnelState is 1 when UP and 0 when DOWN.
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  period              = var.tunnel_alarm_period
  evaluation_periods  = var.tunnel_alarm_evaluation_periods
  datapoints_to_alarm = var.tunnel_alarm_evaluation_periods
  treat_missing_data  = "breaching"

  actions_enabled = var.tunnel_alarm_actions_enabled
  alarm_actions   = var.tunnel_alarm_actions
  ok_actions      = var.tunnel_alarm_actions

  tags = var.tags
}
