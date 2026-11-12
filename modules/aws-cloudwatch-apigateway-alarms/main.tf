locals {
  settings = {
    for name, a in var.apis : name => {
      error_rate_threshold = a.error_rate_threshold != null ? a.error_rate_threshold : var.error_rate_threshold
      min_requests         = a.min_requests != null ? a.min_requests : var.min_requests
      priority             = a.priority != null ? a.priority : var.priority
      anomaly_alarm        = a.anomaly_alarm != null ? a.anomaly_alarm : var.enable_anomaly_alarm
      anomaly_band_width   = a.anomaly_band_width != null ? a.anomaly_band_width : var.anomaly_band_width
    }
  }

  # The 5XX rate, shared by the fixed-threshold alarm and the anomaly alarm. The rate is only meaningful with
  # traffic: below min_requests it reports 0. Count is published as SampleCount, 5XXError as Sum.
  rate_query = {
    for name, s in local.settings : name => [
      {
        id          = "rate"
        expression  = "IF(FILL(req,0) >= ${s.min_requests}, 100 * FILL(err,0) / FILL(req,1), 0)"
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
          dimensions  = { ApiName = name }
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
          dimensions  = { ApiName = name }
        }]
      },
    ]
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
    each.value.priority == null ? "" : "[${each.value.priority}]",
    "More than ${each.value.error_rate_threshold}% of requests to ${each.key} returned 5XX for ${var.period * var.datapoints_to_alarm / 60} minutes (evaluated only when there are at least ${each.value.min_requests} requests per ${var.period / 60} minutes).",
    var.description_suffix,
  ]))

  metric_query = local.rate_query[each.key]

  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.error_rate_threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

# An alarm on a rise of the 5XX rate above the range CloudWatch expects, learned from the metric's own history
# (up to two weeks). It suits an API with a steady, known 5XX rate, where no fixed threshold fits. The
# fixed-threshold alarm stays: during the first weeks the model is still learning.
module "error_rate_anomaly" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = { for name, s in local.settings : name => s if s.anomaly_alarm }

  alarm_name = "${var.name_prefix}-apigw-${each.key}-5xx-rate-anomaly"
  alarm_description = join(" ", compact([
    each.value.priority == null ? "" : "[${each.value.priority}]",
    "The 5XX rate of ${each.key} is above the range CloudWatch expects (anomaly detection band of ${each.value.anomaly_band_width} standard deviations, learned from the previous weeks) for ${var.period * var.datapoints_to_alarm / 60} minutes (evaluated only when there are at least ${each.value.min_requests} requests per ${var.period / 60} minutes).",
    var.description_suffix,
  ]))

  metric_query = concat(local.rate_query[each.key], [
    {
      id          = "band"
      expression  = "ANOMALY_DETECTION_BAND(rate, ${each.value.anomaly_band_width})"
      label       = "Expected 5XX %"
      return_data = true
    },
  ])

  comparison_operator = "GreaterThanUpperThreshold"
  threshold_metric_id = "band"
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
