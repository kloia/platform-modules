# With only the VpnId dimension TunnelState is the average over the connection's tunnels:
# 1 when all are up, between 0 and 1 when at least one is not.
module "tunnel_down" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  alarm_name        = "${var.name_prefix}-vpn-${var.name}-tunnel-down"
  alarm_description = join(" ", compact(["At least one tunnel of this Site-to-Site VPN has been down for ${var.period * var.datapoints_to_alarm / 60} minutes. Traffic may still flow over the other tunnel, but the connection has no redundancy left. Check the tunnel status and the customer gateway.", var.description_suffix]))

  namespace   = "AWS/VPN"
  metric_name = "TunnelState"
  statistic   = "Minimum"
  period      = var.period
  dimensions  = { VpnId = var.vpn_connection_id }

  comparison_operator = "LessThanThreshold"
  threshold           = 1
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  # A connection that stops reporting is not known to be up.
  treat_missing_data = "breaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
