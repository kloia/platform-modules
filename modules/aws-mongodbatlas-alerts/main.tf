# Atlas's own default alerts (email to project members) are left untouched: these are
# separate alert configurations that notify only the targets of their tier.
locals {
  default_alerts = {
    no_primary = {
      event_type  = "NO_PRIMARY"
      tier        = "critical"
      delay_min   = 5
      description = "Replica set has no primary: writes fail."
    }
    cpu_normalized = {
      event_type  = "OUTSIDE_METRIC_THRESHOLD"
      tier        = "critical"
      delay_min   = 10
      description = "Normalized system CPU above 90 % for 10 minutes."
      metric_threshold = {
        metric_name = "NORMALIZED_SYSTEM_CPU_USER"
        operator    = "GREATER_THAN"
        threshold   = 90
      }
    }
    connections_percent = {
      event_type  = "OUTSIDE_METRIC_THRESHOLD"
      tier        = "critical"
      delay_min   = 5
      description = "Connections above 90 % of the tier limit."
      metric_threshold = {
        metric_name = "CONNECTIONS_PERCENT"
        operator    = "GREATER_THAN"
        threshold   = 90
      }
    }
    disk_space_used = {
      event_type  = "OUTSIDE_METRIC_THRESHOLD"
      tier        = "critical"
      delay_min   = 5
      description = "Data disk above 95 %. Storage autoscaling starts at about 90 %, so 95 % means it did not keep up."
      metric_threshold = {
        metric_name = "DISK_PARTITION_SPACE_USED_DATA"
        operator    = "GREATER_THAN"
        threshold   = 95
      }
    }
    unhealthy_members = {
      event_type  = "TOO_MANY_UNHEALTHY_MEMBERS"
      tier        = "warning"
      delay_min   = 15
      description = "A replica set member is unhealthy for 15 minutes. Maintenance restarts are shorter."
      threshold = {
        operator  = "GREATER_THAN"
        threshold = 0
      }
    }
    connections_percent_warn = {
      event_type  = "OUTSIDE_METRIC_THRESHOLD"
      tier        = "warning"
      delay_min   = 5
      description = "Connections above 80 % of the tier limit."
      metric_threshold = {
        metric_name = "CONNECTIONS_PERCENT"
        operator    = "GREATER_THAN"
        threshold   = 80
      }
    }
    replication_lag = {
      event_type  = "OUTSIDE_METRIC_THRESHOLD"
      tier        = "warning"
      delay_min   = 5
      description = "A secondary is more than 5 minutes behind the primary."
      metric_threshold = {
        metric_name = "OPLOG_SLAVE_LAG_MASTER_TIME"
        operator    = "GREATER_THAN"
        threshold   = 300
        units       = "SECONDS"
      }
    }
    oplog_window = {
      event_type  = "REPLICATION_OPLOG_WINDOW_RUNNING_OUT"
      tier        = "warning"
      description = "Oplog window under 1 hour: a lagging secondary may need a full resync."
      threshold = {
        operator  = "LESS_THAN"
        threshold = 1
        units     = "HOURS"
      }
    }
    backup_snapshot_failed = {
      event_type  = "CPS_SNAPSHOT_FAILED"
      tier        = "warning"
      description = "A cloud backup snapshot failed."
    }
    backup_snapshot_behind = {
      event_type  = "CPS_SNAPSHOT_BEHIND"
      tier        = "warning"
      description = "No cloud backup snapshot for over 12 hours (two missed 6-hourly snapshots)."
      # Atlas rejects this event type without a threshold (MISSING_THRESHOLD).
      threshold = {
        operator  = "GREATER_THAN"
        threshold = 12
        units     = "HOURS"
      }
    }
    disk_autoscale_failed = {
      event_type  = "DISK_AUTO_SCALE_MAX_DISK_SIZE_FAIL"
      tier        = "warning"
      description = "Storage autoscaling could not grow the disk: the cluster is at its maximum disk size."
    }
  }

  # Normalise the defaults to the variable's object type so they merge with var.alerts.
  default_alerts_typed = {
    for k, a in local.default_alerts : k => {
      event_type  = a.event_type
      tier        = a.tier
      description = a.description
      enabled     = true
      delay_min   = try(a.delay_min, 0)
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

  targets       = flatten([for t in values(var.tiers) : t.targets])
  ssm_paths     = toset([for x in local.targets : x.api_key_ssm_path if x.type == "OPS_GENIE"])
  uses_slack    = anytrue([for x in local.targets : x.type == "SLACK"])
  unknown_tiers = setsubtract(toset([for a in values(local.alerts) : a.tier]), toset(keys(var.tiers)))
}

data "mongodbatlas_project" "this" {
  name = var.project_name

  lifecycle {
    postcondition {
      condition     = length(local.unknown_tiers) == 0
      error_message = "Alerts reference tiers not defined in var.tiers: ${join(", ", local.unknown_tiers)}."
    }
  }
}

data "aws_ssm_parameter" "api_key" {
  for_each = local.ssm_paths

  name            = each.value
  with_decryption = true
}

# Atlas allows one Slack integration per project. It is connected once in the Atlas UI
# (Project Settings > Integrations > Slack); this fails the plan if it is missing.
data "mongodbatlas_third_party_integration" "slack" {
  count = local.uses_slack ? 1 : 0

  project_id = data.mongodbatlas_project.this.id
  type       = "SLACK"
}

resource "mongodbatlas_alert_configuration" "this" {
  for_each = local.alerts

  project_id        = data.mongodbatlas_project.this.id
  event_type        = each.value.event_type
  enabled           = each.value.enabled
  severity_override = var.tiers[each.value.tier].severity

  # Each Opsgenie notification carries its own key, so the project needs no Opsgenie
  # integration and existing project integrations are never touched.
  dynamic "notification" {
    for_each = var.tiers[each.value.tier].targets
    content {
      type_name         = notification.value.type
      delay_min         = each.value.delay_min
      ops_genie_api_key = notification.value.type == "OPS_GENIE" ? data.aws_ssm_parameter.api_key[notification.value.api_key_ssm_path].value : null
      ops_genie_region  = notification.value.type == "OPS_GENIE" ? notification.value.region : null
      channel_name      = notification.value.type == "SLACK" ? notification.value.channel_name : null
      integration_id    = notification.value.type == "SLACK" ? data.mongodbatlas_third_party_integration.slack[0].id : null
      email_address     = notification.value.type == "EMAIL" ? notification.value.email_address : null
      roles             = notification.value.type == "GROUP" ? notification.value.roles : null
      email_enabled     = notification.value.type == "GROUP" ? true : null
    }
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
