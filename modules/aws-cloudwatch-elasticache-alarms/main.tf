# Nodes are read from the replication group, so a replica or shard added later is covered on the
# next apply.
data "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
}

locals {
  # A sorted list keeps the m0..mN query ids stable between plans.
  nodes = sort(tolist(data.aws_elasticache_replication_group.this.member_clusters))

  minutes = var.period * var.datapoints_to_alarm / 60

  # MAX over every node keeps the alarm valid after a primary failover.
  alarms = {
    engine-cpu = {
      metric = "EngineCPUUtilization", stat = "Average", threshold = var.engine_cpu_threshold, missing = "missing"
      label  = "Engine CPU % (worst node)"
      text   = "Redis engine thread CPU above ${var.engine_cpu_threshold}% for ${local.minutes} minutes on a node of this replication group. Redis runs commands on one thread, so this is the limit, not host CPU. Look for slow or O(N) commands (SLOWLOG) before resizing."
    }
    memory = {
      metric = "DatabaseMemoryUsagePercentage", stat = "Average", threshold = var.memory_threshold_pct, missing = "missing"
      label  = "Memory used % of maxmemory (worst node)"
      text   = "Redis memory above ${var.memory_threshold_pct}% of maxmemory for ${local.minutes} minutes. At 100% keys are evicted or writes fail, depending on maxmemory-policy. Check key growth and TTLs."
    }
    evictions = {
      metric = "Evictions", stat = "Sum", threshold = var.evictions_threshold, missing = "notBreaching"
      label  = "Evicted keys per period (worst node)"
      text   = "Redis evicting keys for ${local.minutes} minutes: memory is full and keys are being dropped. Check memory usage and key TTLs."
    }
  }
}

module "alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.alarms

  alarm_name        = "${var.name_prefix}-redis-${var.name}-${each.key}-high"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, n in local.nodes : "m${i}"])}])"
      label       = each.value.label
      return_data = true
    }],
    [for i, n in local.nodes : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/ElastiCache"
        metric_name = each.value.metric
        stat        = each.value.stat
        period      = var.period
        dimensions  = { CacheClusterId = n }
      }]
    }]
  )

  comparison_operator = "GreaterThanThreshold"
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = each.value.missing

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
