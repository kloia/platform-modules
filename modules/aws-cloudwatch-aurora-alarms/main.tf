# Instances are read from the cluster, so a reader added later is covered on the
# next apply, and sizes come from the live instance class, not from code.
data "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_identifier

  lifecycle {
    postcondition {
      condition     = length(self.cluster_members) <= 10
      error_message = "A metric math alarm can include at most 10 metrics; this cluster has more than 10 instances."
    }
  }
}

data "aws_db_instance" "this" {
  for_each = data.aws_rds_cluster.this.cluster_members

  db_instance_identifier = each.value
}

data "aws_ec2_instance_type" "this" {
  for_each = toset([for i in data.aws_db_instance.this : trimprefix(i.db_instance_class, "db.")])

  instance_type = each.value
}

locals {
  # Lists keep a stable order for the m0..mN query ids.
  instances = sort(tolist(data.aws_rds_cluster.this.cluster_members))
  class     = { for id in local.instances : id => data.aws_db_instance.this[id].db_instance_class }

  memory_bytes = { for id in local.instances : id => data.aws_ec2_instance_type.this[trimprefix(local.class[id], "db.")].memory_size * 1048576 }
  storage_gib  = merge(local.local_storage_gib, var.local_storage_gib)
  # A class missing from the table fails the plan with an "Invalid index" naming it; add it to local_storage_gib.
  storage_bytes = { for id in local.instances : id => floor(local.storage_gib[local.class[id]] * 1073741824) }

  minutes  = var.period * var.datapoints_to_alarm / 60
  postgres = data.aws_rds_cluster.this.engine == "aurora-postgresql"

  # Aurora PostgreSQL default: LEAST({DBInstanceClassMemory/9531392},5000). The instance type's memory is a
  # little above DBInstanceClassMemory, so the computed limit is slightly high and the alarm slightly late.
  max_connections = {
    for id in local.instances : id => coalesce(var.max_connections, min(floor(local.memory_bytes[id] / 9531392), 5000))
  }

  # MAX/MIN over every instance keeps the alarm valid after a writer failover.
  worst = {
    cpu = {
      metric = "CPUUtilization", stat = "Average", fn = "MAX", op = "GreaterThanThreshold", threshold = var.cpu_threshold, missing = "missing"
      label  = "CPU % (worst instance)"
      text   = "Aurora CPU above ${var.cpu_threshold}% for ${local.minutes} minutes on an instance of this cluster. Check Performance Insights top SQL and wait events before resizing."
    }
    deadlocks = {
      metric = "Deadlocks", stat = "Average", fn = "MAX", op = "GreaterThanThreshold", threshold = var.deadlocks_threshold, missing = "notBreaching"
      label  = "Deadlocks per second (worst instance)"
      text   = "Aurora deadlocks above ${var.deadlocks_threshold}/s for ${local.minutes} minutes. Find the conflicting transactions in the database log."
    }
    dbload = {
      metric = "DBLoadRelativeToNumVCPUs", stat = "Average", fn = "MAX", op = "GreaterThanThreshold", threshold = var.dbload_threshold, missing = "notBreaching"
      label  = "DB load per vCPU (worst instance)"
      text   = "Aurora average active sessions above ${var.dbload_threshold}x the vCPU count for ${local.minutes} minutes. Lock waits with low CPU are contention, not capacity."
    }
    replica-lag = {
      metric = "AuroraReplicaLag", stat = "Average", fn = "MAX", op = "GreaterThanThreshold", threshold = var.replica_lag_threshold_ms, missing = "notBreaching"
      label  = "Replica lag ms (worst reader)"
      text   = "Aurora reader lag above ${var.replica_lag_threshold_ms / 1000} s for ${local.minutes} minutes; reads from a replica return stale data. Check writer load and long-running transactions."
    }
    transaction-ids = {
      metric = "MaximumUsedTransactionIDs", stat = "Maximum", fn = "MAX", op = "GreaterThanThreshold", threshold = var.transaction_ids_threshold, missing = "missing"
      label  = "Oldest unvacuumed transaction ID age (worst instance)"
      text   = "Oldest unvacuumed transaction ID above ${var.transaction_ids_threshold}. Near 2.1 billion PostgreSQL stops accepting writes until a single-user vacuum. Find what blocks autovacuum (long transactions, abandoned replication slots, prepared transactions)."
    }
  }

  # Each instance as a percentage of its own size, then the lowest: instances of one cluster can differ in class.
  pct = {
    freeable-memory = {
      metric = "FreeableMemory", stat = "Average", threshold = var.freeable_memory_threshold_pct, bytes = local.memory_bytes
      label  = "Freeable memory % (lowest instance)"
      text   = "Aurora freeable memory below ${var.freeable_memory_threshold_pct}% of the instance's memory for ${local.minutes} minutes. Check connection count and memory-heavy queries."
    }
    local-storage = {
      metric = "FreeLocalStorage", stat = "Minimum", threshold = var.local_storage_threshold_pct, bytes = local.storage_bytes
      label  = "Free local storage % (lowest instance)"
      text   = "Aurora local storage (temporary tables, sorts) below ${var.local_storage_threshold_pct}% of the instance's capacity for ${local.minutes} minutes. Look for large sorts or temp files."
    }
  }

  worst_enabled = {
    for k, v in local.worst : k => v
    if !(k == "dbload" && !var.enable_dbload_alarm) && !(k == "replica-lag" && length(local.instances) < 2) && !(k == "transaction-ids" && !local.postgres)
  }

  # The default limit is the PostgreSQL formula; other engines alarm only with max_connections set.
  connections_enabled = local.postgres || var.max_connections != null

  instance_metrics = [
    for i, id in local.instances : {
      id = "m${i}", dimensions = { DBInstanceIdentifier = id }
    }
  ]
}

module "worst" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.worst_enabled

  alarm_name        = "${var.name_prefix}-aurora-${var.name}-${each.key}-high"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "${each.value.fn}([${join(",", [for m in local.instance_metrics : m.id])}])"
      label       = each.value.label
      return_data = true
    }],
    [for m in local.instance_metrics : {
      id          = m.id
      return_data = false
      metric = [{
        namespace   = "AWS/RDS"
        metric_name = each.value.metric
        stat        = each.value.stat
        period      = var.period
        dimensions  = m.dimensions
      }]
    }]
  )

  comparison_operator = each.value.op
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = each.value.missing

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

module "pct" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.pct

  alarm_name        = "${var.name_prefix}-aurora-${var.name}-${each.key}-low"
  alarm_description = join(" ", compact([each.value.text, var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MIN([${join(",", [for i, id in local.instances : "p${i}"])}])"
      label       = each.value.label
      return_data = true
    }],
    [for i, id in local.instances : {
      id          = "p${i}"
      expression  = "100 * m${i} / ${each.value.bytes[id]}"
      return_data = false
    }],
    [for m in local.instance_metrics : {
      id          = m.id
      return_data = false
      metric = [{
        namespace   = "AWS/RDS"
        metric_name = each.value.metric
        stat        = each.value.stat
        period      = var.period
        dimensions  = m.dimensions
      }]
    }]
  )

  comparison_operator = "LessThanThreshold"
  threshold           = each.value.threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

# Each instance against its own limit, then the highest.
module "connections" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  count = local.connections_enabled ? 1 : 0

  alarm_name        = "${var.name_prefix}-aurora-${var.name}-connections-high"
  alarm_description = join(" ", compact(["Aurora connections above ${var.connections_threshold_pct}% of max_connections for ${local.minutes} minutes on an instance of this cluster. At the limit new connections fail. Look for connection leaks or pool sizes before raising the limit.", var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, id in local.instances : "p${i}"])}])"
      label       = "Connections % of max_connections (worst instance)"
      return_data = true
    }],
    [for i, id in local.instances : {
      id          = "p${i}"
      expression  = "100 * m${i} / ${local.max_connections[id]}"
      return_data = false
    }],
    [for m in local.instance_metrics : {
      id          = m.id
      return_data = false
      metric = [{
        namespace   = "AWS/RDS"
        metric_name = "DatabaseConnections"
        stat        = "Maximum"
        period      = var.period
        dimensions  = m.dimensions
      }]
    }]
  )

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.connections_threshold_pct
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}

# Published in the secondary region against the secondary cluster, so this belongs on the secondary.
module "global_lag" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  count = var.enable_global_replication_lag_alarm ? 1 : 0

  alarm_name        = "${var.name_prefix}-aurora-${var.name}-global-lag-high"
  alarm_description = join(" ", compact(["Aurora Global replication to this secondary cluster above ${var.global_replication_lag_threshold_ms / 1000} s for ${local.minutes} minutes. Its readers serve stale data, and a failover now would lose the unreplicated writes. Check the primary's write load.", var.description_suffix]))

  namespace   = "AWS/RDS"
  metric_name = "AuroraGlobalDBReplicationLag"
  statistic   = "Maximum"
  period      = var.period
  dimensions  = { DBClusterIdentifier = var.cluster_identifier }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.global_replication_lag_threshold_ms
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
