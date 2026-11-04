# Gateways are looked up by ID so a wrong ID fails the plan instead of leaving an
# alarm that never receives data.
data "aws_ec2_transit_gateway" "this" {
  for_each = var.gateways

  id = each.value.id
}

locals {
  settings = {
    for label, g in var.gateways : label => {
      id                  = data.aws_ec2_transit_gateway.this[label].id
      blackhole_threshold = g.blackhole_threshold != null ? g.blackhole_threshold : var.blackhole_threshold
      no_route_threshold  = g.no_route_threshold != null ? g.no_route_threshold : var.no_route_threshold
    }
  }

  alarms = merge([
    for label, s in local.settings : merge(
      {
        "${label}-blackhole" = {
          alarm_name          = "${var.name_prefix}-tgw-${label}-blackhole"
          description         = "Transit gateway ${label} (${s.id}) dropped at least ${s.blackhole_threshold} packets in ${var.period / 60} minutes because they matched a blackhole route."
          namespace           = "AWS/TransitGateway"
          metric_name         = "PacketDropCountBlackhole"
          statistic           = "Sum"
          dimensions          = { TransitGateway = s.id }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.blackhole_threshold
        }
      },
      var.enable_no_route_alarm ? {
        "${label}-no-route" = {
          alarm_name          = "${var.name_prefix}-tgw-${label}-no-route"
          description         = "Transit gateway ${label} (${s.id}) dropped at least ${s.no_route_threshold} packets in ${var.period / 60} minutes because they matched no route."
          namespace           = "AWS/TransitGateway"
          metric_name         = "PacketDropCountNoRoute"
          statistic           = "Sum"
          dimensions          = { TransitGateway = s.id }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.no_route_threshold
        }
      } : {},
    )
  ]...)
}

module "alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.alarms

  alarm_name          = each.value.alarm_name
  alarm_description   = join(" ", compact([each.value.description, var.description_suffix]))
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  statistic           = each.value.statistic
  period              = var.period
  dimensions          = each.value.dimensions
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
