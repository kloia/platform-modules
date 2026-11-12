# CloudFront publishes its metrics only in us-east-1, so the AWS provider passed to this module
# must be configured for that region; an alarm anywhere else would stay green and never fire.
# `region` exists from provider 6, `name` before it (and is deprecated from 6): try both, so neither warns.
data "aws_region" "current" {}

# Looked up so that an ID matching nothing fails the plan instead of creating an alarm without data.
data "aws_cloudfront_distribution" "this" {
  for_each = var.distributions

  id = each.value.id

  lifecycle {
    precondition {
      condition     = try(data.aws_region.current.region, data.aws_region.current.name) == "us-east-1"
      error_message = "CloudFront metrics exist only in us-east-1: configure the AWS provider of this module for that region."
    }
  }
}

locals {
  alarms = {
    for label, d in var.distributions : label => {
      id           = d.id
      threshold    = d.error_rate_threshold != null ? d.error_rate_threshold : var.error_rate_threshold
      min_requests = d.min_requests != null ? d.min_requests : var.min_requests
    }
  }
}

module "alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.alarms

  alarm_name = "${var.name_prefix}-cloudfront-${each.key}-5xx-rate"
  alarm_description = join(" ", compact([
    var.priority == null ? "" : "[${var.priority}]",
    "More than ${each.value.threshold}% of viewer requests to CloudFront distribution ${each.key} (${each.value.id}) returned 5XX for ${var.period * var.datapoints_to_alarm / 60} minutes (evaluated only when there are at least ${each.value.min_requests} requests per ${var.period / 60} minutes).",
    var.description_suffix,
  ]))

  # The rate is only meaningful with traffic: below min_requests it reports 0.
  metric_query = [
    {
      id          = "rate"
      expression  = "IF(FILL(req,0) >= ${each.value.min_requests}, FILL(err,0), 0)"
      label       = "5XX error rate %"
      return_data = true
    },
    {
      id          = "req"
      return_data = false
      metric = [{
        namespace   = "AWS/CloudFront"
        metric_name = "Requests"
        stat        = "Sum"
        period      = var.period
        dimensions  = { DistributionId = each.value.id, Region = "Global" }
      }]
    },
    {
      id          = "err"
      return_data = false
      metric = [{
        namespace   = "AWS/CloudFront"
        metric_name = "5xxErrorRate"
        stat        = "Average"
        period      = var.period
        dimensions  = { DistributionId = each.value.id, Region = "Global" }
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
