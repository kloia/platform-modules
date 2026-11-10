# Load balancers and target groups are looked up by name: a load balancer recreated by a
# controller keeps its name but gets a new ID, and a hard-coded ID would leave the alarm without data.
data "aws_lb" "this" {
  for_each = var.load_balancers

  name = each.key
}

locals {
  target_groups = toset(flatten([for lb in var.load_balancers : lb.target_group_names]))

  # At most 10 target groups per alarm: CloudWatch allows 10 metrics in one metric math alarm.
  groups = merge([
    for lb, v in var.load_balancers : {
      for i, names in chunklist(sort(v.target_group_names), 10) : "${lb}-${i}" => {
        lb     = lb
        names  = names
        suffix = i == 0 ? "" : "-${i + 1}"
      }
    }
  ]...)

  health = {
    unhealthy-hosts = {
      metric              = "UnHealthyHostCount"
      stat                = "Minimum"
      combine             = "MAX"
      comparison_operator = "GreaterThanThreshold"
      threshold           = var.unhealthy_hosts_threshold
      missing             = "notBreaching"
      text                = "A target group of the Network Load Balancer %s has more than ${var.unhealthy_hosts_threshold} unhealthy targets on every load balancer node for ${var.period * var.datapoints_to_alarm / 60} minutes."
    }
    no-healthy-hosts = {
      metric              = "HealthyHostCount"
      stat                = "Maximum"
      combine             = "MIN"
      comparison_operator = "LessThanThreshold"
      threshold           = var.min_healthy_hosts
      missing             = var.treat_missing_healthy_data
      text                = "A target group of the Network Load Balancer %s has fewer than ${var.min_healthy_hosts} healthy targets for ${var.period * var.datapoints_to_alarm / 60} minutes, or no registered targets."
    }
  }

  health_alarms = merge([
    for gk, g in local.groups : {
      for kind, h in local.health : "${gk}-${kind}" => merge(h, { group = g, kind = kind, lb = g.lb })
    }
  ]...)
}

data "aws_lb_target_group" "this" {
  for_each = local.target_groups

  name = each.key
}

module "health" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.health_alarms

  alarm_name = "${var.name_prefix}-nlb-${each.value.lb}-${each.value.kind}${each.value.group.suffix}"
  alarm_description = join(" ", compact([
    format(each.value.text, each.value.lb),
    var.description_suffix,
  ]))

  # One query per target group, then the worst of them: MAX for the unhealthy count, MIN for the healthy count.
  metric_query = concat(
    [{
      id          = "worst"
      expression  = "${each.value.combine}([${join(",", [for i, n in each.value.group.names : "m${i}"])}])"
      label       = "${each.value.metric} (worst target group)"
      return_data = true
    }],
    [for i, n in each.value.group.names : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/NetworkELB"
        metric_name = each.value.metric
        stat        = each.value.stat
        period      = var.period
        dimensions = {
          LoadBalancer = data.aws_lb.this[each.value.lb].arn_suffix
          TargetGroup  = data.aws_lb_target_group.this[n].arn_suffix
        }
      }]
    }]
  )

  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = each.value.missing

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

module "port_allocation" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = var.load_balancers

  alarm_name = "${var.name_prefix}-nlb-${each.key}-port-allocation-errors"
  alarm_description = join(" ", compact([
    "The Network Load Balancer ${each.key} had at least ${var.port_allocation_errors_threshold} ephemeral port allocation errors in ${var.period / 60} minutes: client connections are being dropped because a target has too many connections.",
    var.description_suffix,
  ]))

  namespace   = "AWS/NetworkELB"
  metric_name = "PortAllocationErrorCount"
  statistic   = "Sum"
  period      = var.period
  dimensions  = { LoadBalancer = data.aws_lb.this[each.key].arn_suffix }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.port_allocation_errors_threshold
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
