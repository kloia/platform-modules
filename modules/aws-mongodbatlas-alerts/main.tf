# Each alert here notifies Opsgenie only. The default alerts Atlas creates in every
# project (email to project members) are left untouched, so a condition covered by both
# notifies by email and by Opsgenie.
locals {
  default_alerts = {
    no_primary = {
      event_type = "NO_PRIMARY"
      delay_min  = 5
    }
    primary_elected = {
      event_type = "PRIMARY_ELECTED"
    }
    host_down = {
      event_type = "HOST_DOWN"
      delay_min  = 5
    }
    disk_space_used = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      delay_min  = 5
      metric_threshold = {
        metric_name = "DISK_PARTITION_SPACE_USED_DATA"
        operator    = "GREATER_THAN"
        threshold   = 85
      }
    }
    connections_percent = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      delay_min  = 5
      metric_threshold = {
        metric_name = "CONNECTIONS_PERCENT"
        operator    = "GREATER_THAN"
        threshold   = 80
      }
    }
    replication_lag = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      delay_min  = 5
      metric_threshold = {
        metric_name = "OPLOG_SLAVE_LAG_MASTER_TIME"
        operator    = "GREATER_THAN"
        threshold   = 300
        units       = "SECONDS"
      }
    }
    oplog_window = {
      event_type = "REPLICATION_OPLOG_WINDOW_RUNNING_OUT"
      threshold = {
        operator  = "LESS_THAN"
        threshold = 1
        units     = "HOURS"
      }
    }
    cpu_normalized = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      delay_min  = 10
      metric_threshold = {
        metric_name = "NORMALIZED_SYSTEM_CPU_USER"
        operator    = "GREATER_THAN"
        threshold   = 90
      }
    }
    cpu_iowait = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      delay_min  = 10
      metric_threshold = {
        metric_name = "SYSTEM_NORMALIZED_CPU_IOWAIT"
        operator    = "GREATER_THAN"
        threshold   = 30
      }
    }
    backup_snapshot_failed = {
      event_type = "CPS_SNAPSHOT_FAILED"
    }
    backup_snapshot_behind = {
      event_type = "CPS_SNAPSHOT_BEHIND"
    }
  }

  # Normalise the defaults to the variable's object type, so they merge with var.alerts.
  default_alerts_typed = {
    for k, a in local.default_alerts : k => {
      event_type = a.event_type
      enabled    = true
      delay_min  = try(a.delay_min, 0)
      metric_threshold = try(a.metric_threshold, null) == null ? null : {
        metric_name = a.metric_threshold.metric_name
        operator    = a.metric_threshold.operator
        threshold   = a.metric_threshold.threshold
        units       = try(a.metric_threshold.units, "RAW")
        mode        = "AVERAGE"
      }
      threshold = try(a.threshold, null) == null ? null : {
        operator  = a.threshold.operator
        threshold = a.threshold.threshold
        units     = try(a.threshold.units, null)
      }
      matchers = []
    }
  }

  alerts = merge(var.enable_default_alerts ? local.default_alerts_typed : {}, var.alerts)

  integration_id = var.create_opsgenie_integration ? mongodbatlas_third_party_integration.opsgenie[0].id : data.mongodbatlas_third_party_integration.opsgenie[0].id
}

data "mongodbatlas_project" "this" {
  name = var.project_name
}

resource "mongodbatlas_third_party_integration" "opsgenie" {
  count = var.create_opsgenie_integration ? 1 : 0

  project_id = data.mongodbatlas_project.this.id
  type       = "OPS_GENIE"
  api_key    = var.opsgenie_api_key
  region     = var.opsgenie_region

  lifecycle {
    precondition {
      condition     = var.opsgenie_api_key != null
      error_message = "opsgenie_api_key is required when create_opsgenie_integration is true."
    }
  }
}

data "mongodbatlas_third_party_integration" "opsgenie" {
  count = var.create_opsgenie_integration ? 0 : 1

  project_id = data.mongodbatlas_project.this.id
  type       = "OPS_GENIE"
}

resource "mongodbatlas_alert_configuration" "this" {
  for_each = local.alerts

  project_id = data.mongodbatlas_project.this.id
  event_type = each.value.event_type
  enabled    = each.value.enabled

  notification {
    type_name        = "OPS_GENIE"
    integration_id   = local.integration_id
    ops_genie_region = var.opsgenie_region
    delay_min        = each.value.delay_min
  }

  dynamic "metric_threshold_config" {
    for_each = each.value.metric_threshold == null ? [] : [each.value.metric_threshold]
    content {
      metric_name = metric_threshold_config.value.metric_name
      operator    = metric_threshold_config.value.operator
      threshold   = metric_threshold_config.value.threshold
      units       = metric_threshold_config.value.units
      mode        = metric_threshold_config.value.mode
    }
  }

  dynamic "threshold_config" {
    for_each = each.value.threshold == null ? [] : [each.value.threshold]
    content {
      operator  = threshold_config.value.operator
      threshold = threshold_config.value.threshold
      units     = threshold_config.value.units
    }
  }

  dynamic "matcher" {
    for_each = each.value.matchers
    content {
      field_name = matcher.value.field_name
      operator   = matcher.value.operator
      value      = matcher.value.value
    }
  }
}
