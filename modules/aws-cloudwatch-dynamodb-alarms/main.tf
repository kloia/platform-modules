# Tables are looked up by name so a misspelt or deleted table fails the plan
# instead of leaving an alarm that never receives data.
data "aws_dynamodb_table" "this" {
  for_each = var.tables

  name = each.key
}

locals {
  settings = {
    for name, t in var.tables : name => {
      read_throttle_threshold  = t.read_throttle_threshold != null ? t.read_throttle_threshold : var.read_throttle_threshold
      write_throttle_threshold = t.write_throttle_threshold != null ? t.write_throttle_threshold : var.write_throttle_threshold
    }
  }

  alarms = merge([
    for name, s in local.settings : merge(
      var.enable_read_throttle_alarm ? {
        "${name}-read-throttle" = {
          alarm_name          = "${var.name_prefix}-dynamodb-${name}-read-throttle"
          description         = "At least ${s.read_throttle_threshold} read throttle events on table ${name} in ${var.period / 60} minutes: reads are being refused for lack of capacity."
          namespace           = "AWS/DynamoDB"
          metric_name         = "ReadThrottleEvents"
          statistic           = "Sum"
          dimensions          = { TableName = data.aws_dynamodb_table.this[name].name }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.read_throttle_threshold
        }
      } : {},
      var.enable_write_throttle_alarm ? {
        "${name}-write-throttle" = {
          alarm_name          = "${var.name_prefix}-dynamodb-${name}-write-throttle"
          description         = "At least ${s.write_throttle_threshold} write throttle events on table ${name} in ${var.period / 60} minutes: writes are being refused for lack of capacity."
          namespace           = "AWS/DynamoDB"
          metric_name         = "WriteThrottleEvents"
          statistic           = "Sum"
          dimensions          = { TableName = data.aws_dynamodb_table.this[name].name }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = s.write_throttle_threshold
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
