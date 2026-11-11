# Atlas's own default alerts (email to project members) are left untouched: these are
# separate alert configurations that notify only the targets of their tier.
locals {
  default_alerts = {
    no_primary = {
      title       = "No Primary"
      event_type  = "NO_PRIMARY"
      tier        = "critical"
      delay_min   = 5
      description = "Replica set has no primary: writes fail."
    }
    cpu_normalized = {
      title       = "CPU Usage"
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
      title       = "Connection Usage"
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
      title       = "Disk Usage"
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
      title       = "Unhealthy Replica Set Member"
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
      title       = "Connection Usage"
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
      title       = "Replication Lag"
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
      title       = "Oplog Window"
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
      title       = "Backup Snapshot Failed"
      event_type  = "CPS_SNAPSHOT_FAILED"
      tier        = "warning"
      description = "A cloud backup snapshot failed."
    }
    backup_snapshot_behind = {
      title       = "Backup Snapshot Behind"
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
      title       = "Disk Autoscale Failed"
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
      title       = a.title
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
  uses_opsgenie = anytrue([for x in local.targets : x.type == "OPS_GENIE"])
  uses_webhook  = anytrue([for x in local.targets : x.type == "WEBHOOK"])
  uses_slack    = anytrue([for x in local.targets : x.type == "SLACK"])
  unknown_tiers = setsubtract(toset([for a in values(local.alerts) : a.tier]), toset(keys(var.tiers)))

  manage_opsgenie = local.uses_opsgenie && !try(var.opsgenie.use_existing_integration, false)
  opsgenie_integration_id = one(concat(
    mongodbatlas_third_party_integration.opsgenie[*].id,
    data.mongodbatlas_third_party_integration.opsgenie[*].id,
  ))

  manage_webhook = local.uses_webhook && !try(var.webhook.use_existing_integration, false)

  # Atlas renders this with FreeMarker and test-renders it against sample data on save.
  # Use eventType, not event: templates reading event were rejected. projectName arrives
  # empty, so the project name comes from var.project_name.
  slack_project       = trim(jsonencode(var.project_name), "\"")
  slack_body_template = <<-EOT
    {"text": "*MongoDB Atlas* $${eventType?replace('alert.open', 'ALARM')?replace('alert.close', 'OK')?replace('alert.cancel', 'CANCELLED')?replace('alert.update', 'STILL FIRING')}: __TITLE__ · ${local.slack_project} / $${(clusterName!'-')?json_string}",
     "attachments": [{"color": "$${eventType?replace('alert.open', '#d40e0d')?replace('alert.close', '#2eb886')?replace('alert.cancel', '#cccccc')?replace('alert.update', '#d40e0d')?replace('alert.acknowledge', '#daa038')?replace('alert.inform', '#daa038')}", "blocks": [
       {"type": "section", "text": {"type": "mrkdwn", "text": "$${eventType?replace('alert.open', ':rotating_light:')?replace('alert.close', ':white_check_mark:')?replace('alert.cancel', ':heavy_minus_sign:')?replace('alert.update', ':rotating_light:')?replace('alert.acknowledge', ':bell:')?replace('alert.inform', ':bell:')} *MongoDB Atlas · __TITLE__*\n${local.slack_project} / $${(clusterName!'-')?json_string}"}},
       {"type": "section", "fields": [
         {"type": "mrkdwn", "text": "*Current value*\n*$${((currentValue.number?is_number)?then(currentValue.number?string('0.#'), currentValue.number) + '__UNIT__')!'-'}*"},
         {"type": "mrkdwn", "text": "*__TIER__ threshold*\n*__THRESHOLD__*"},
         {"type": "mrkdwn", "text": "*State*\n$${eventType?replace('alert.open', 'ALARM')?replace('alert.close', 'OK')?replace('alert.cancel', 'CANCELLED')?replace('alert.update', 'STILL FIRING')}"}
       ]},
       {"type": "actions", "elements": [{"type": "button", "text": {"type": "plain_text", "text": "Open in Atlas"}, "url": "https://cloud.mongodb.com/v2/$${groupId}#/alerts"}]}
     ]}]}
  EOT
  webhook_body_template = try(coalesce(
    try(var.webhook.body_template, null),
    try(var.webhook.format, null) == "SLACK" ? local.slack_body_template : null,
  ), null)
  # Per-alert text the module writes into the template: __TITLE__, __THRESHOLD__, __UNIT__, __TIER__.
  percent_metrics = ["CONNECTIONS_PERCENT", "NORMALIZED_SYSTEM_CPU_USER", "DISK_PARTITION_SPACE_USED_DATA"]
  unit_suffix     = { RAW = "", SECONDS = " s", MINUTES = " min", HOURS = " h", BYTES = " B", MEGABYTES = " MB", GIGABYTES = " GB" }
  operator_word   = { GREATER_THAN = "above", LESS_THAN = "below" }
  alert_display = {
    for k, a in local.alerts : k => {
      title = coalesce(a.title, k)
      unit = a.metric_threshold == null ? "" : (
        contains(local.percent_metrics, a.metric_threshold.metric_name) ? "%" : lookup(local.unit_suffix, a.metric_threshold.units, "")
      )
      threshold = (
        a.metric_threshold != null ? format("%s %s%s", lookup(local.operator_word, a.metric_threshold.operator, a.metric_threshold.operator), a.metric_threshold.threshold,
        contains(local.percent_metrics, a.metric_threshold.metric_name) ? "%" : lookup(local.unit_suffix, a.metric_threshold.units, "")) :
        a.threshold != null ? format("%s %s%s", lookup(local.operator_word, a.threshold.operator, a.threshold.operator), a.threshold.threshold, lookup(local.unit_suffix, coalesce(a.threshold.units, "RAW"), "")) :
        "-"
      )
    }
  }
  webhook_integration_id = one(concat(
    mongodbatlas_third_party_integration.webhook[*].id,
    data.mongodbatlas_third_party_integration.webhook[*].id,
  ))
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

data "aws_ssm_parameter" "opsgenie" {
  count = local.manage_opsgenie ? 1 : 0

  name            = var.opsgenie.api_key_ssm_path
  with_decryption = true
}

# Atlas holds one Opsgenie integration per project, and an alert notification that carries
# a key without an integration makes Atlas create one. The module owns that integration, so
# every alert references it and is created after it.
resource "mongodbatlas_third_party_integration" "opsgenie" {
  count = local.manage_opsgenie ? 1 : 0

  project_id = data.mongodbatlas_project.this.id
  type       = "OPS_GENIE"
  api_key    = data.aws_ssm_parameter.opsgenie[0].value
  region     = var.opsgenie.region
}

data "mongodbatlas_third_party_integration" "opsgenie" {
  count = local.uses_opsgenie && !local.manage_opsgenie ? 1 : 0

  project_id = data.mongodbatlas_project.this.id
  type       = "OPS_GENIE"
}

data "aws_ssm_parameter" "webhook" {
  count = local.manage_webhook ? 1 : 0

  name            = var.webhook.url_ssm_path
  with_decryption = true
}

# Same as Opsgenie: one webhook integration per project, owned by the module.
resource "mongodbatlas_third_party_integration" "webhook" {
  count = local.manage_webhook ? 1 : 0

  project_id = data.mongodbatlas_project.this.id
  type       = "WEBHOOK"
  url        = data.aws_ssm_parameter.webhook[0].value
}

data "mongodbatlas_third_party_integration" "webhook" {
  count = local.uses_webhook && !local.manage_webhook ? 1 : 0

  project_id = data.mongodbatlas_project.this.id
  type       = "WEBHOOK"
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

  dynamic "notification" {
    for_each = var.tiers[each.value.tier].targets
    content {
      type_name         = notification.value.type
      delay_min         = each.value.delay_min
      ops_genie_api_key = notification.value.type == "OPS_GENIE" && local.manage_opsgenie ? data.aws_ssm_parameter.opsgenie[0].value : null
      ops_genie_region  = notification.value.type == "OPS_GENIE" ? var.opsgenie.region : null
      webhook_url       = notification.value.type == "WEBHOOK" && local.manage_webhook ? data.aws_ssm_parameter.webhook[0].value : null
      # Placeholders become the alert's own text, escaped for a JSON string.
      webhook_body_template = notification.value.type == "WEBHOOK" && local.webhook_body_template != null ? replace(replace(replace(replace(replace(
        local.webhook_body_template,
        "__ALERT_DESCRIPTION__", trim(jsonencode(coalesce(each.value.description, each.key)), "\"")),
        "__TITLE__", trim(jsonencode(local.alert_display[each.key].title), "\"")),
        "__THRESHOLD__", trim(jsonencode(local.alert_display[each.key].threshold), "\"")),
        "__UNIT__", local.alert_display[each.key].unit),
        "__TIER__", title(each.value.tier)
      ) : null
      # Atlas rejects a WEBHOOK notification without a re-notify interval of at least 5 minutes.
      interval_min = notification.value.type == "WEBHOOK" ? 60 : null
      channel_name = notification.value.type == "SLACK" ? notification.value.channel_name : null
      integration_id = (
        notification.value.type == "OPS_GENIE" ? local.opsgenie_integration_id :
        notification.value.type == "WEBHOOK" ? (local.manage_webhook ? null : local.webhook_integration_id) :
        notification.value.type == "SLACK" ? data.mongodbatlas_third_party_integration.slack[0].id : null
      )
      email_address = notification.value.type == "EMAIL" ? notification.value.email_address : null
      roles         = notification.value.type == "GROUP" ? notification.value.roles : null
      email_enabled = notification.value.type == "GROUP" ? true : null
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
