# Queues are looked up by name so a misspelt or deleted queue fails the plan
# instead of leaving an alarm that never receives data.
data "aws_sqs_queue" "this" {
  for_each = var.queues

  name = each.key
}

locals {
  metrics = {
    visible = { name = "ApproximateNumberOfMessagesVisible", statistic = "Maximum", what = "waiting in" }
    sent    = { name = "NumberOfMessagesSent", statistic = "Sum", what = "written to" }
  }

  settings = {
    for name, q in var.queues : name => {
      threshold = q.messages_threshold != null ? q.messages_threshold : var.messages_threshold
      metric    = local.metrics[q.metric != null ? q.metric : var.metric]
    }
  }
}

module "alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.settings

  alarm_name = "${var.name_prefix}-sqs-${each.key}-messages"
  alarm_description = join(" ", compact([
    var.priority == null ? "" : "[${var.priority}]",
    "At least ${each.value.threshold} messages ${each.value.metric.what} ${each.key} in ${var.period / 60} minutes.",
    var.description_suffix,
  ]))

  namespace           = "AWS/SQS"
  metric_name         = each.value.metric.name
  statistic           = each.value.metric.statistic
  period              = var.period
  dimensions          = { QueueName = data.aws_sqs_queue.this[each.key].name }
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm

  # SQS publishes these only while the queue is active; an idle queue is not a breach.
  treat_missing_data = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
