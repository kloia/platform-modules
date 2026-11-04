# Gateways are looked up by ID so a wrong ID fails the plan instead of leaving an
# alarm that never receives data.
data "aws_nat_gateway" "this" {
  for_each = var.gateways

  id = each.value.id
}

locals {
  settings = {
    for label, g in var.gateways : label => {
      id                              = data.aws_nat_gateway.this[label].id
      error_port_allocation_threshold = g.error_port_allocation_threshold != null ? g.error_port_allocation_threshold : var.error_port_allocation_threshold
      packets_drop_threshold          = g.packets_drop_threshold != null ? g.packets_drop_threshold : var.packets_drop_threshold
    }
  }

  alarms = merge([
    for label, s in local.settings : {
      "${label}-port-allocation" = {
        alarm_name          = "${var.name_prefix}-nat-${label}-port-allocation"
        description         = "NAT gateway ${label} (${s.id}) failed to allocate a source port at least ${s.error_port_allocation_threshold} times in ${var.period / 60} minutes: too many concurrent connections are open through it."
        namespace           = "AWS/NATGateway"
        metric_name         = "ErrorPortAllocation"
        statistic           = "Sum"
        dimensions          = { NatGatewayId = s.id }
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = s.error_port_allocation_threshold
      }
      "${label}-packets-dropped" = {
        alarm_name          = "${var.name_prefix}-nat-${label}-packets-dropped"
        description         = "NAT gateway ${label} (${s.id}) dropped at least ${s.packets_drop_threshold} packets in ${var.period / 60} minutes."
        namespace           = "AWS/NATGateway"
        metric_name         = "PacketsDropCount"
        statistic           = "Sum"
        dimensions          = { NatGatewayId = s.id }
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = s.packets_drop_threshold
      }
    }
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
