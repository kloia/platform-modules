# Functions are looked up by name so the configured timeout can be read from the
# function instead of being copied into the caller, where it would go stale.
data "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = each.key
}

locals {
  # A null override falls back to the module-wide default; an explicit 0 is kept.
  settings = {
    for name, f in var.functions : name => {
      error_rate_threshold        = f.error_rate_threshold != null ? f.error_rate_threshold : var.error_rate_threshold
      min_invocations             = f.min_invocations != null ? f.min_invocations : var.min_invocations
      throttle_threshold          = f.throttle_threshold != null ? f.throttle_threshold : var.throttle_threshold
      duration_percent_of_timeout = f.duration_percent_of_timeout != null ? f.duration_percent_of_timeout : var.duration_percent_of_timeout
      timeout_seconds             = data.aws_lambda_function.this[name].timeout
    }
  }

  window_minutes = var.period * var.datapoints_to_alarm / 60
}

module "error_rate" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.settings

  alarm_name = "${var.name_prefix}-lambda-${each.key}-error-rate"
  alarm_description = join(" ", compact([
    "More than ${each.value.error_rate_threshold}% of invocations of ${each.key} failed for ${local.window_minutes} minutes (evaluated only when there are at least ${each.value.min_invocations} invocations per ${var.period / 60} minutes).",
    var.description_suffix,
  ]))

  # The rate is only meaningful with traffic: below min_invocations it reports 0.
  metric_query = [
    {
      id          = "rate"
      expression  = "IF(FILL(inv,0) >= ${each.value.min_invocations}, 100 * FILL(err,0) / FILL(inv,1), 0)"
      label       = "Error rate %"
      return_data = true
    },
    {
      id          = "inv"
      return_data = false
      metric = [{
        namespace   = "AWS/Lambda"
        metric_name = "Invocations"
        stat        = "Sum"
        period      = var.period
        dimensions  = { FunctionName = each.key }
      }]
    },
    {
      id          = "err"
      return_data = false
      metric = [{
        namespace   = "AWS/Lambda"
        metric_name = "Errors"
        stat        = "Sum"
        period      = var.period
        dimensions  = { FunctionName = each.key }
      }]
    },
  ]

  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.error_rate_threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

# Any throttle means a concurrency limit was hit and a request was refused, so one
# period is enough; waiting for several would only delay the page.
module "throttles" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.settings

  alarm_name = "${var.name_prefix}-lambda-${each.key}-throttles"
  alarm_description = join(" ", compact([
    "${each.key} had at least ${each.value.throttle_threshold} throttled invocations in ${var.period / 60} minutes: a concurrency limit was reached and requests were refused.",
    var.description_suffix,
  ]))

  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  statistic           = "Sum"
  period              = var.period
  dimensions          = { FunctionName = each.key }
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = each.value.throttle_threshold
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

module "duration" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.settings

  alarm_name = "${var.name_prefix}-lambda-${each.key}-duration"
  alarm_description = join(" ", compact([
    "p99 duration of ${each.key} exceeded ${each.value.duration_percent_of_timeout}% of its ${each.value.timeout_seconds}s timeout for ${local.window_minutes} minutes: invocations are close to being cut off.",
    var.description_suffix,
  ]))

  namespace          = "AWS/Lambda"
  metric_name        = "Duration"
  extended_statistic = "p99"
  period             = var.period
  dimensions         = { FunctionName = each.key }

  # Duration is reported in milliseconds; the timeout is in seconds.
  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.timeout_seconds * 1000 * each.value.duration_percent_of_timeout / 100
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
