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
      priority                    = f.priority != null ? f.priority : var.priority
      timeout_seconds             = data.aws_lambda_function.this[name].timeout
    }
  }

  window_minutes = var.period * var.datapoints_to_alarm / 60

  # One entry per function and alarm kind. Fields a kind does not use are null.
  alarms = merge([
    for name, s in local.settings : merge(
      {
        "${name}-error-rate" = {
          function            = name
          priority            = s.priority
          alarm_name          = "${var.name_prefix}-lambda-${name}-error-rate"
          description         = "More than ${s.error_rate_threshold}% of invocations of ${name} failed for ${local.window_minutes} minutes (evaluated only when there are at least ${s.min_invocations} invocations per ${var.period / 60} minutes)."
          comparison_operator = "GreaterThanThreshold"
          threshold           = s.error_rate_threshold
          evaluation_periods  = var.evaluation_periods
          datapoints_to_alarm = var.datapoints_to_alarm
          metric_name         = null
          statistic           = null
          extended_statistic  = null
          # The rate is only meaningful with traffic: below min_invocations it reports 0.
          metric_query = concat([
            {
              id          = "rate"
              expression  = "IF(FILL(inv,0) >= ${s.min_invocations}, 100 * FILL(err,0) / FILL(inv,1), 0)"
              label       = "Error rate %"
              return_data = true
            }
            ], [
            for id, metric in { inv = "Invocations", err = "Errors" } : {
              id                    = id
              return_data           = false
              metric = [{
                namespace   = "AWS/Lambda"
                metric_name = metric
                stat        = "Sum"
                period      = var.period
                dimensions  = { FunctionName = name }
              }]
            }
          ])
        }
      },

      # Any throttle means a concurrency limit was hit and a request was refused, so one
      # period is enough; waiting for several would only delay the page.
      var.enable_throttle_alarm ? {
        "${name}-throttles" = {
          function            = name
          priority            = s.priority
          alarm_name          = "${var.name_prefix}-lambda-${name}-throttles"
          description         = "${name} had at least ${s.throttle_threshold} throttled invocations in ${var.period / 60} minutes: a concurrency limit was reached and requests were refused."
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.throttle_threshold
          evaluation_periods  = 1
          datapoints_to_alarm = 1
          metric_name         = "Throttles"
          statistic           = "Sum"
          extended_statistic  = null
          metric_query        = []
        }
      } : {},

      # Duration is reported in milliseconds; the timeout is in seconds.
      var.enable_duration_alarm ? {
        "${name}-duration" = {
          function            = name
          priority            = s.priority
          alarm_name          = "${var.name_prefix}-lambda-${name}-duration"
          description         = "p99 duration of ${name} exceeded ${s.duration_percent_of_timeout}% of its ${s.timeout_seconds}s timeout for ${local.window_minutes} minutes: invocations are close to being cut off."
          comparison_operator = "GreaterThanThreshold"
          threshold           = s.timeout_seconds * 1000 * s.duration_percent_of_timeout / 100
          evaluation_periods  = var.evaluation_periods
          datapoints_to_alarm = var.datapoints_to_alarm
          metric_name         = "Duration"
          statistic           = null
          extended_statistic  = "p99"
          metric_query        = []
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
  alarm_description   = join(" ", compact([each.value.priority == null ? "" : "[${each.value.priority}]", each.value.description, var.description_suffix]))
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  # Plain-metric alarms (throttles, duration); the error rate uses metric_query instead.
  namespace          = length(each.value.metric_query) == 0 ? "AWS/Lambda" : null
  metric_name        = each.value.metric_name
  statistic          = each.value.statistic
  extended_statistic = each.value.extended_statistic
  period             = length(each.value.metric_query) == 0 ? var.period : null
  dimensions         = length(each.value.metric_query) == 0 ? { FunctionName = each.value.function } : null
  metric_query       = each.value.metric_query

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
