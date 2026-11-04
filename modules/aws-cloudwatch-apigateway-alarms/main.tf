locals {
  settings = {
    for name, a in var.apis : name => {
      error_rate_threshold = a.error_rate_threshold != null ? a.error_rate_threshold : var.error_rate_threshold
      min_requests         = a.min_requests != null ? a.min_requests : var.min_requests
    }
  }
}

# APIs are not looked up: the ApiName dimension is a name, and API Gateway allows two
# REST APIs to share one, which a by-name lookup would reject. Metrics of APIs that
# share a name are reported under the same dimension and are alarmed on together.
module "error_rate" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.settings

  alarm_name = "${var.name_prefix}-apigw-${each.key}-5xx-rate"
  alarm_description = join(" ", compact([
    "More than ${each.value.error_rate_threshold}% of requests to ${each.key} returned 5XX for ${var.period * var.datapoints_to_alarm / 60} minutes (evaluated only when there are at least ${each.value.min_requests} requests per ${var.period / 60} minutes).",
    var.description_suffix,
  ]))

  # The rate is only meaningful with traffic: below min_requests it reports 0.
  # Count is published as SampleCount, 5XXError as Sum.
  metric_query = [
    {
      id          = "rate"
      expression  = "IF(FILL(req,0) >= ${each.value.min_requests}, 100 * FILL(err,0) / FILL(req,1), 0)"
      label       = "5XX %"
      return_data = true
    },
    {
      id          = "req"
      return_data = false
      metric = [{
        namespace   = "AWS/ApiGateway"
        metric_name = "Count"
        stat        = "SampleCount"
        period      = var.period
        dimensions  = { ApiName = each.key }
      }]
    },
    {
      id          = "err"
      return_data = false
      metric = [{
        namespace   = "AWS/ApiGateway"
        metric_name = "5XXError"
        stat        = "Sum"
        period      = var.period
        dimensions  = { ApiName = each.key }
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
