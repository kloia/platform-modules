# aws-mongodbatlas-alerts

Adds alert configurations to an existing MongoDB Atlas project and sends them, by tier, to
Opsgenie, Slack, email or project members. The project is looked up by name, so the caller
needs no dependency on the stack that created it.

- **Tiers.** Each alert belongs to a tier. A tier lists its targets and an optional
  `severity` (`INFO`, `WARNING`, `ERROR`, `CRITICAL`), set as the alerts' `severity_override`.
  The default alerts use the tiers `critical` and `warning`.
- **Opsgenie.** Each notification carries the API key itself, read from an SSM
  SecureString (`api_key_ssm_path`). The project needs no Opsgenie integration, and existing
  project integrations are not touched. Atlas sends no priority: set it in Opsgenie (on the
  integration, or with an alert policy on the alert text or severity).
- **Slack.** A `SLACK` target posts to `channel_name` through the project's Atlas Slack
  integration, connected once per project in the Atlas UI (Project Settings > Integrations >
  Slack). The plan fails if a tier uses Slack and the project has no Slack integration.
- **Atlas's own default alerts are left alone.** Every project starts with email alerts for
  some of the same conditions; this module adds separate configurations.
- Opsgenie keys end up in Terraform state. Keep the state encrypted and access-restricted.

## Default alerts

| Key | Event / metric | Condition | Delay (min) | Tier |
|---|---|---|---|---|
| `no_primary` | `NO_PRIMARY` | no primary | 5 | critical |
| `cpu_normalized` | `NORMALIZED_SYSTEM_CPU_USER` | > 90 % | 10 | critical |
| `connections_percent` | `CONNECTIONS_PERCENT` | > 90 % of the tier limit | 5 | critical |
| `disk_space_used` | `DISK_PARTITION_SPACE_USED_DATA` | > 95 % | 5 | critical |
| `unhealthy_members` | `TOO_MANY_UNHEALTHY_MEMBERS` | > 0 | 15 | warning |
| `connections_percent_warn` | `CONNECTIONS_PERCENT` | > 80 % of the tier limit | 5 | warning |
| `replication_lag` | `OPLOG_SLAVE_LAG_MASTER_TIME` | > 300 s | 5 | warning |
| `oplog_window` | `REPLICATION_OPLOG_WINDOW_RUNNING_OUT` | < 1 h | 0 | warning |
| `backup_snapshot_failed` | `CPS_SNAPSHOT_FAILED` | snapshot failed | 0 | warning |
| `backup_snapshot_behind` | `CPS_SNAPSHOT_BEHIND` | scheduled snapshot late | 0 | warning |
| `disk_autoscale_failed` | `DISK_AUTO_SCALE_MAX_DISK_SIZE_FAIL` | storage autoscale at max size | 0 | warning |

- Disk pages at 95 %, not 90 %: storage autoscaling starts at about 90 %, so a 90 % alert
  fires on every successful autoscale.
- `unhealthy_members` waits 15 minutes because a maintenance restart takes a member down for
  less than that. `HOST_DOWN` and `PRIMARY_ELECTED` are not defaults: both fire on every
  scheduled maintenance.
- Disk IOPS is not a default: its threshold depends on each cluster's provisioned IOPS.

## Usage

```hcl
module "atlas_alerts" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-mongodbatlas-alerts/v0.1.0"

  project_name = "example-project"

  tiers = {
    critical = {
      severity = "CRITICAL"
      targets  = [{ type = "OPS_GENIE", api_key_ssm_path = "/example/alerting/opsgenie_api_key", region = "EU" }]
    }
    warning = {
      severity = "WARNING"
      targets = [
        { type = "OPS_GENIE", api_key_ssm_path = "/example/alerting/opsgenie_api_key", region = "EU" },
        { type = "SLACK", channel_name = "#example-db-alerts" },
      ]
    }
  }

  alerts = {
    # Same key as a default: replaces it.
    cpu_normalized = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      tier       = "critical"
      delay_min  = 15
      metric_threshold = {
        metric_name = "NORMALIZED_SYSTEM_CPU_USER"
        operator    = "GREATER_THAN"
        threshold   = 95
      }
    }
    # New key: added. 90 % of a cluster provisioned at 3000 IOPS.
    disk_iops = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      tier       = "warning"
      delay_min  = 10
      metric_threshold = {
        metric_name = "DISK_PARTITION_IOPS_TOTAL"
        operator    = "GREATER_THAN"
        threshold   = 2700
      }
    }
  }
}
```

Credentials: the `mongodbatlas` provider reads `MONGODB_ATLAS_PUBLIC_KEY` and
`MONGODB_ATLAS_PRIVATE_KEY`, or a service account's `MONGODB_ATLAS_CLIENT_ID` and
`MONGODB_ATLAS_CLIENT_SECRET`, and needs Project Owner. The `aws` provider needs
`ssm:GetParameter` and `kms:Decrypt` on the key's parameter.

A caller that generates its own `versions.tf` over this module (for example a Terragrunt
`generate` with `if_exists = "overwrite"`) loses the module's provider requirements.
Terraform then resolves `hashicorp/mongodbatlas`, which does not exist. List both
`mongodb/mongodbatlas` and `hashicorp/aws` in the generated file, or generate into an
`*_override.tf` file instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 2.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 2.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_alert_configuration.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/alert_configuration) | resource |
| [aws_ssm_parameter.api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [mongodbatlas_project.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |
| [mongodbatlas_third_party_integration.slack](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/third_party_integration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alerts"></a> [alerts](#input\_alerts) | Alerts added to the default set, keyed by a stable name. A key that matches a default replaces it entirely. description is for the code and docs only; Atlas has no field for it. | <pre>map(object({<br>    event_type  = string<br>    tier        = string<br>    description = optional(string)<br>    enabled     = optional(bool, true)<br>    delay_min   = optional(number, 0)<br>    metric_threshold = optional(object({<br>      metric_name = string<br>      operator    = string<br>      threshold   = number<br>      units       = optional(string, "RAW")<br>      mode        = optional(string, "AVERAGE")<br>    }))<br>    threshold = optional(object({<br>      operator  = string<br>      threshold = number<br>      units     = optional(string)<br>    }))<br>    matchers = optional(list(object({<br>      field_name = string<br>      operator   = string<br>      value      = string<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_enable_default_alerts"></a> [enable\_default\_alerts](#input\_enable\_default\_alerts) | Create the default alert set (see README). Set false to create only the entries in alerts. | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Atlas project name, looked up by name, so the caller needs no dependency on the unit that creates the project. | `string` | n/a | yes |
| <a name="input_tiers"></a> [tiers](#input\_tiers) | Where each tier's alerts are sent. severity becomes the alerts' severity\_override (INFO, WARNING, ERROR, CRITICAL). Target types: OPS\_GENIE (api\_key\_ssm\_path, region), SLACK (channel\_name, uses the project's Slack integration), EMAIL (email\_address), GROUP (roles). The default alerts use the tiers critical and warning. | <pre>map(object({<br>    severity = optional(string)<br>    targets = list(object({<br>      type             = string<br>      api_key_ssm_path = optional(string)<br>      region           = optional(string, "US")<br>      channel_name     = optional(string)<br>      email_address    = optional(string)<br>      roles            = optional(list(string))<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_configuration_ids"></a> [alert\_configuration\_ids](#output\_alert\_configuration\_ids) | Atlas alert configuration ID of each alert, by key. |
<!-- END_TF_DOCS -->
