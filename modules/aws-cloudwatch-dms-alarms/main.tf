# Instances are looked up by identifier so the allocated storage can be read from the
# instance, and a misspelt identifier fails the plan.
data "aws_dms_replication_instance" "this" {
  for_each = var.replication_instances

  replication_instance_id = each.key
}

locals {
  instances = {
    for id, i in var.replication_instances : id => {
      cpu_threshold              = i.cpu_threshold != null ? i.cpu_threshold : var.cpu_threshold
      free_storage_threshold_pct = i.free_storage_threshold_pct != null ? i.free_storage_threshold_pct : var.free_storage_threshold_pct
      allocated_gib              = data.aws_dms_replication_instance.this[id].allocated_storage
    }
  }

  tasks = {
    for arn, t in var.replication_tasks : arn => {
      name                       = element(split(":", arn), 6)
      replication_instance       = t.replication_instance
      cdc_latency_source_seconds = t.cdc_latency_source_seconds != null ? t.cdc_latency_source_seconds : var.cdc_latency_source_seconds
      cdc_latency_target_seconds = t.cdc_latency_target_seconds != null ? t.cdc_latency_target_seconds : var.cdc_latency_target_seconds
    }
  }

  alarms = merge(
    merge([
      for id, i in local.instances : {
        "${id}-cpu" = {
          alarm_name          = "${var.name_prefix}-dms-${id}-cpu"
          description         = "CPU on DMS replication instance ${id} reached ${i.cpu_threshold}% for ${var.period * var.datapoints_to_alarm / 60} minutes."
          namespace           = "AWS/DMS"
          metric_name         = "CPUUtilization"
          statistic           = "Maximum"
          dimensions          = { ReplicationInstanceIdentifier = id }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = i.cpu_threshold
        }
        "${id}-free-storage" = {
          alarm_name          = "${var.name_prefix}-dms-${id}-free-storage"
          description         = "Free storage on DMS replication instance ${id} is below ${i.free_storage_threshold_pct}% of its ${i.allocated_gib} GiB for ${var.period * var.datapoints_to_alarm / 60} minutes. Task logs and cached changes fill it; the instance stops at storage-full."
          namespace           = "AWS/DMS"
          metric_name         = "FreeStorageSpace"
          statistic           = "Minimum"
          dimensions          = { ReplicationInstanceIdentifier = id }
          comparison_operator = "LessThanThreshold"
          threshold           = floor(i.allocated_gib * 1073741824 * i.free_storage_threshold_pct / 100)
        }
      }
    ]...),
    merge([
      for arn, t in local.tasks : {
        "${t.name}-cdc-latency-source" = {
          alarm_name          = "${var.name_prefix}-dms-${t.name}-cdc-latency-source"
          description         = "CDC latency from the source of DMS task ${t.name} reached ${t.cdc_latency_source_seconds} seconds for ${var.period * var.datapoints_to_alarm / 60} minutes: capturing changes from the source is delayed."
          namespace           = "AWS/DMS"
          metric_name         = "CDCLatencySource"
          statistic           = "Maximum"
          dimensions          = { ReplicationInstanceIdentifier = t.replication_instance, ReplicationTaskIdentifier = t.name }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = t.cdc_latency_source_seconds
        }
        "${t.name}-cdc-latency-target" = {
          alarm_name          = "${var.name_prefix}-dms-${t.name}-cdc-latency-target"
          description         = "CDC latency to the target of DMS task ${t.name} reached ${t.cdc_latency_target_seconds} seconds for ${var.period * var.datapoints_to_alarm / 60} minutes: applying changes to the target is delayed."
          namespace           = "AWS/DMS"
          metric_name         = "CDCLatencyTarget"
          statistic           = "Maximum"
          dimensions          = { ReplicationInstanceIdentifier = t.replication_instance, ReplicationTaskIdentifier = t.name }
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = t.cdc_latency_target_seconds
        }
      }
    ]...),
  )
}

module "alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  for_each = local.alarms

  alarm_name          = each.value.alarm_name
  alarm_description   = join(" ", compact([var.priority == null ? "" : "[${var.priority}]", each.value.description, var.description_suffix]))
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
