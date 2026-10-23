# Brokers are read from the cluster, so a broker added later is covered on the next apply.
data "aws_msk_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_msk_broker_nodes" "this" {
  cluster_arn = data.aws_msk_cluster.this.arn

  lifecycle {
    postcondition {
      condition     = length(self.node_info_list) <= 5
      error_message = "A metric math alarm can include at most 10 metrics, and the CPU alarm reads two per broker; this cluster has more than 5 brokers."
    }
  }
}

locals {
  # Sorted, and as strings: the Broker ID dimension is "1", not 1.
  brokers = sort([for n in data.aws_msk_broker_nodes.this.node_info_list : tostring(n.broker_id)])

  minutes = var.period * var.datapoints_to_alarm / 60

  # Published once per cluster (dimension "Cluster Name" only).
  cluster = {
    offline-partitions = {
      metric = "OfflinePartitionsCount", op = "GreaterThanThreshold", threshold = 0, datapoints = 1, suffix = "high", missing = "missing"
      text   = "Kafka has partitions with no leader: producers and consumers of those partitions are failing now. Check broker health and recent restarts."
    }
    active-controller = {
      # Missing data counts as breaching: a cluster that stops publishing has no controller either.
      metric = "ActiveControllerCount", op = "LessThanThreshold", threshold = 1, datapoints = var.datapoints_to_alarm, suffix = "low", missing = "breaching"
      text   = "No active Kafka controller for ${local.minutes} minutes: partition leadership and topic changes are stuck. Check broker health."
    }
  }

  # Published per broker; MAX over brokers.
  broker = {
    under-replicated = {
      metric = "UnderReplicatedPartitions", threshold = 0
      label  = "Under-replicated partitions (worst broker)"
      text   = "Kafka partitions under-replicated for ${local.minutes} minutes: a broker is behind or down, and losing another one can lose data. Check broker CPU, disk and network."
    }
    disk-used = {
      metric = "KafkaDataLogsDiskUsed", threshold = var.disk_used_threshold_pct
      label  = "Data log disk used % (worst broker)"
      text   = "Kafka data log disk above ${var.disk_used_threshold_pct}% on a broker for ${local.minutes} minutes. A full disk stops the broker. Check retention or expand storage."
    }
  }
}

module "cluster" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.cluster

  alarm_name        = "${var.name_prefix}-kafka-${var.name}-${each.key}-${each.value.suffix}"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  namespace   = "AWS/Kafka"
  metric_name = each.value.metric
  statistic   = "Maximum"
  period      = var.period
  dimensions  = { "Cluster Name" = var.cluster_name }

  comparison_operator = each.value.op
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = each.value.datapoints
  treat_missing_data  = each.value.missing

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

module "broker" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.broker

  alarm_name        = "${var.name_prefix}-kafka-${var.name}-${each.key}-high"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, b in local.brokers : "m${i}"])}])"
      label       = each.value.label
      return_data = true
    }],
    [for i, b in local.brokers : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/Kafka"
        metric_name = each.value.metric
        stat        = "Maximum"
        period      = var.period
        dimensions  = { "Cluster Name" = var.cluster_name, "Broker ID" = b }
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

# CpuUser + CpuSystem per broker, then the worst broker. AWS recommends keeping it under 60% so the
# cluster has headroom when a broker is replaced or patched.
module "cpu" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  alarm_name        = "${var.name_prefix}-kafka-${var.name}-cpu-high"
  alarm_description = join(" ", compact(["Kafka broker CPU (user + system) above ${var.cpu_threshold_pct}% for ${local.minutes} minutes. Above 60% the cluster has no headroom for a broker failure or a rolling update. Check partition balance and client load before scaling up.", var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, b in local.brokers : "c${i}"])}])"
      label       = "CPU user + system % (worst broker)"
      return_data = true
    }],
    [for i, b in local.brokers : {
      id          = "c${i}"
      expression  = "u${i} + s${i}"
      return_data = false
    }],
    flatten([for i, b in local.brokers : [
      for k, m in { u = "CpuUser", s = "CpuSystem" } : {
        id            = "${k}${i}"
        return_data   = false
        metric = [{
          namespace   = "AWS/Kafka"
          metric_name = m
          stat        = "Average"
          period      = var.period
          dimensions  = { "Cluster Name" = var.cluster_name, "Broker ID" = b }
        }]
      }
    ]])
  )

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold_pct
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
