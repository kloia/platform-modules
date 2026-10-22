# Engine and deployment mode are read from the broker, so the right alarm set follows the broker.
data "aws_mq_broker" "this" {
  broker_name = var.broker_name
}

locals {
  activemq = data.aws_mq_broker.this.engine_type == "ActiveMQ"
  minutes  = var.period * var.datapoints_to_alarm / 60

  # ActiveMQ publishes per instance (<name>-1, <name>-2); only the active one has data, so MAX over both
  # follows a failover.
  instance_numbers = data.aws_mq_broker.this.deployment_mode == "SINGLE_INSTANCE" ? [1] : [1, 2]
  instances        = [for i in local.instance_numbers : "${var.broker_name}-${i}"]

  activemq_alarms = {
    heap = {
      metric = "HeapUsage", threshold = var.heap_threshold_pct
      label  = "JVM heap used % (active instance)"
      text   = "ActiveMQ JVM heap above ${var.heap_threshold_pct}% for ${local.minutes} minutes. Near 100% the broker blocks producers or restarts. Check slow consumers and pending messages; flat traffic with growing heap points to a leak."
    }
    store = {
      metric = "StorePercentUsage", threshold = var.store_threshold_pct
      label  = "Persistent store used % (active instance)"
      text   = "ActiveMQ persistent store above ${var.store_threshold_pct}% for ${local.minutes} minutes. At the limit producers are blocked. Check queues with growing depth and no consumers."
    }
  }

  # RabbitMQ: the broker-level series carries the same values as the nodes, so node names (which change
  # on replacement) are not needed. Each alarm is a ratio of a metric to its limit.
  rabbitmq_alarms = {
    memory = {
      used       = "RabbitMQMemUsed", limit = "RabbitMQMemLimit", op = "GreaterThanThreshold", threshold = var.memory_threshold_pct
      expression = "100 * used / limit", suffix = "high"
      label      = "Memory used % of the high watermark"
      text       = "RabbitMQ memory above ${var.memory_threshold_pct}% of its high watermark for ${local.minutes} minutes. At 100% publishers are blocked. Check queue depth and unacked messages."
    }
    disk-free = {
      used       = "RabbitMQDiskFree", limit = "RabbitMQDiskFreeLimit", op = "LessThanThreshold", threshold = var.disk_free_limit_multiple
      expression = "used / limit", suffix = "low"
      label      = "Free disk as a multiple of the disk alarm limit"
      text       = "RabbitMQ free disk below ${var.disk_free_limit_multiple}x its disk alarm limit for ${local.minutes} minutes. At the limit publishers are blocked. Check queue depth."
    }
  }
}

module "activemq" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.activemq ? local.activemq_alarms : {}

  alarm_name        = "${var.name_prefix}-mq-${var.name}-${each.key}-high"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, n in local.instances : "m${i}"])}])"
      label       = each.value.label
      return_data = true
    }],
    [for i, n in local.instances : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/AmazonMQ"
        metric_name = each.value.metric
        stat        = "Average"
        period      = var.period
        dimensions  = { Broker = n }
      }]
    }]
  )

  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

module "rabbitmq" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.activemq ? {} : local.rabbitmq_alarms

  alarm_name        = "${var.name_prefix}-mq-${var.name}-${each.key}-${each.value.suffix}"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  metric_query = [
    {
      id          = "ratio"
      expression  = each.value.expression
      label       = each.value.label
      return_data = true
    },
    {
      id          = "used"
      return_data = false
      metric = [{
        namespace   = "AWS/AmazonMQ"
        metric_name = each.value.used
        stat        = "Maximum"
        period      = var.period
        dimensions  = { Broker = var.broker_name }
      }]
    },
    {
      id          = "limit"
      return_data = false
      metric = [{
        namespace   = "AWS/AmazonMQ"
        metric_name = each.value.limit
        stat        = "Minimum"
        period      = var.period
        dimensions  = { Broker = var.broker_name }
      }]
    },
  ]

  comparison_operator = each.value.op
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

# A broker that is down or unreachable publishes nothing, and every alarm above then sits in
# INSUFFICIENT_DATA. This one watches a metric that is always published while the broker runs and
# fires only when it stops: no datapoint can be below 0, so missing data is the only way to breach.
module "no_data" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  alarm_name        = "${var.name_prefix}-mq-${var.name}-no-data"
  alarm_description = join(" ", compact(["Amazon MQ broker published no metrics for ${local.minutes} minutes: it is down, restarting or unreachable. Check the broker status and recent events in the Amazon MQ console.", var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = local.activemq ? "MAX([${join(",", [for i, n in local.instances : "m${i}"])}])" : "m0"
      label       = local.activemq ? "CPU % (active instance)" : "System CPU %"
      return_data = true
    }],
    local.activemq ? [for i, n in local.instances : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/AmazonMQ"
        metric_name = "CpuUtilization"
        stat        = "Maximum"
        period      = var.period
        dimensions  = { Broker = n }
      }]
      }] : [{
      id          = "m0"
      return_data = false
      metric = [{
        namespace   = "AWS/AmazonMQ"
        metric_name = "SystemCpuUtilization"
        stat        = "Maximum"
        period      = var.period
        dimensions  = { Broker = var.broker_name }
      }]
    }]
  )

  comparison_operator = "LessThanThreshold"
  threshold           = 0
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "breaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
