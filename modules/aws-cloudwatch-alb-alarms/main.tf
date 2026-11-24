# ALBs are looked up by name: a load balancer recreated by a controller keeps its
# name but gets a new ID, and a hard-coded ID would leave the alarm without data.
data "aws_lb" "this" {
  for_each = var.load_balancer_names

  name = each.value
}

locals {
  kinds = {
    target = {
      metric_name = "HTTPCode_Target_5XX_Count"
      threshold   = var.target_5xx_threshold
      source      = "the targets (applications)"
    }
    elb = {
      metric_name = "HTTPCode_ELB_5XX_Count"
      threshold   = var.elb_5xx_threshold
      source      = "the load balancer itself (no healthy target, timeouts, connection errors)"
    }
  }

  alarms = merge([
    for name in var.load_balancer_names : {
      for kind, k in local.kinds : "${name}-${kind}" => merge(k, { lb = name, kind = kind })
      if !(kind == "target" && contains(var.target_5xx_excluded, name))
    }
  ]...)
}

module "alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.alarms

  alarm_name = "${var.name_prefix}-alb-${each.value.lb}-${each.value.kind}-5xx-rate"
  alarm_description = join(" ", compact([
    var.priority == null ? "" : "[${var.priority}]",
    "More than ${each.value.threshold}% of requests on ${each.value.lb} returned 5XX from ${each.value.source} for ${var.period * var.datapoints_to_alarm / 60} minutes (evaluated only when there are at least ${var.min_requests} requests per ${var.period / 60} minutes).",
    var.description_suffix,
  ]))

  # The rate is only meaningful with traffic: below min_requests it reports 0.
  metric_query = [
    {
      id          = "rate"
      expression  = "IF(FILL(req,0) >= ${var.min_requests}, 100 * FILL(err,0) / FILL(req,1), 0)"
      label       = "${each.value.kind} 5XX %"
      return_data = true
    },
    {
      id          = "req"
      return_data = false
      metric = [{
        namespace   = "AWS/ApplicationELB"
        metric_name = "RequestCount"
        stat        = "Sum"
        period      = var.period
        dimensions  = { LoadBalancer = data.aws_lb.this[each.value.lb].arn_suffix }
      }]
    },
    {
      id          = "err"
      return_data = false
      metric = [{
        namespace   = "AWS/ApplicationELB"
        metric_name = each.value.metric_name
        stat        = "Sum"
        period      = var.period
        dimensions  = { LoadBalancer = data.aws_lb.this[each.value.lb].arn_suffix }
      }]
    },
  ]

  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

# Target groups are looked up by name for the same reason as the load balancers.
data "aws_lb_target_group" "healthy_host" {
  for_each = var.healthy_host_target_groups

  name = each.value

  lifecycle {
    postcondition {
      condition     = length(self.load_balancer_arns) == 1
      error_message = "Target group ${each.value} must be attached to exactly one load balancer."
    }
  }
}

data "aws_lb" "healthy_host" {
  for_each = var.healthy_host_target_groups

  arn = one(data.aws_lb_target_group.healthy_host[each.key].load_balancer_arns)
}

module "healthy_host_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = var.healthy_host_target_groups

  alarm_name = "${var.name_prefix}-tg-${each.value}-healthy-hosts"
  alarm_description = join(" ", compact([
    var.priority == null ? "" : "[${var.priority}]",
    "Fewer than ${var.min_healthy_hosts} healthy target(s) in ${each.value} behind ${data.aws_lb.healthy_host[each.key].name} for ${var.healthy_host_period * var.healthy_host_datapoints_to_alarm / 60} minutes, at any traffic level.",
    var.description_suffix,
  ]))

  namespace   = "AWS/ApplicationELB"
  metric_name = "HealthyHostCount"
  statistic   = "Minimum"
  period      = var.healthy_host_period
  dimensions = {
    TargetGroup  = data.aws_lb_target_group.healthy_host[each.key].arn_suffix
    LoadBalancer = data.aws_lb.healthy_host[each.key].arn_suffix
  }

  comparison_operator = "LessThanThreshold"
  threshold           = var.min_healthy_hosts
  evaluation_periods  = var.healthy_host_evaluation_periods
  datapoints_to_alarm = var.healthy_host_datapoints_to_alarm
  # No data means no target reported healthy, which is the case this alarm exists for.
  treat_missing_data = "breaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
