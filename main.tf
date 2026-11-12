# State machines are looked up by name: the metrics are keyed by ARN, and a misspelt
# name fails the plan instead of leaving an alarm that never receives data.
data "aws_sfn_state_machine" "this" {
  for_each = var.state_machines

  name = each.key
}

locals {
  settings = {
    for name, s in var.state_machines : name => {
      failed_threshold    = s.failed_threshold != null ? s.failed_threshold : var.failed_threshold
      timed_out_threshold = s.timed_out_threshold != null ? s.timed_out_threshold : var.timed_out_threshold
      throttled_threshold = s.throttled_threshold != null ? s.throttled_threshold : var.throttled_threshold
    }
  }

  alarms = merge([
    for name, s in local.settings : merge(
      {
        "${name}-failed" = {
          alarm_name          = "${var.name_prefix}-sfn-${name}-failed"
          description         = "At least ${s.failed_threshold} executions of ${name} failed in ${var.period / 60} minutes."
          namespace           = "AWS/States"
          metric_name         = "ExecutionsFailed"
          statistic           = "Sum"
          dimensions          = { StateMachineArn = data.aws_sfn_state_machine.this[name].arn }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.failed_threshold
        }
        "${name}-timed-out" = {
          alarm_name          = "${var.name_prefix}-sfn-${name}-timed-out"
          description         = "At least ${s.timed_out_threshold} executions of ${name} timed out in ${var.period / 60} minutes."
          namespace           = "AWS/States"
          metric_name         = "ExecutionsTimedOut"
          statistic           = "Sum"
          dimensions          = { StateMachineArn = data.aws_sfn_state_machine.this[name].arn }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.timed_out_threshold
        }
      },
      var.enable_throttled_alarm ? {
        "${name}-throttled" = {
          alarm_name          = "${var.name_prefix}-sfn-${name}-throttled"
          description         = "At least ${s.throttled_threshold} state entries or retries of ${name} were throttled in ${var.period / 60} minutes."
          namespace           = "AWS/States"
          metric_name         = "ExecutionThrottled"
          statistic           = "Sum"
          dimensions          = { StateMachineArn = data.aws_sfn_state_machine.this[name].arn }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.throttled_threshold
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
  alarm_description   = join(" ", compact([var.priority == null ? "" : "[${var.priority}]", each.value.description, var.description_suffix]))
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
