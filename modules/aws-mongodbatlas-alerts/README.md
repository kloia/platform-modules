# aws-mongodbatlas-alerts

Sends critical alerts from an existing MongoDB Atlas project to Opsgenie. The project is
looked up by name, so the caller needs no dependency on the stack that created it.

- **Priority is set in Opsgenie, not here.** Atlas sends no priority with an Opsgenie
  notification. The priority comes from the Opsgenie integration whose API key you pass.
- **One Opsgenie integration per project.** Atlas allows one. If the project already has
  one, set `create_opsgenie_integration = false` and the alerts notify that integration.
- **Atlas's own default alerts are left alone.** Every project starts with email alerts for
  some of the same conditions. This module adds separate alert configurations that notify
  Opsgenie only, so a condition in both sets sends an email and an Opsgenie alert.
- The integration's API key is stored in Terraform state. Keep the state encrypted and
  access-restricted.

## Default alerts

| Key | Event / metric | Condition | Delay (min) |
|---|---|---|---|
| `no_primary` | `NO_PRIMARY` | replica set has no primary | 5 |
| `primary_elected` | `PRIMARY_ELECTED` | a new primary was elected | 0 |
| `host_down` | `HOST_DOWN` | host is down | 5 |
| `disk_space_used` | `DISK_PARTITION_SPACE_USED_DATA` | > 85 % | 5 |
| `connections_percent` | `CONNECTIONS_PERCENT` | > 80 % of the connection limit | 5 |
| `replication_lag` | `OPLOG_SLAVE_LAG_MASTER_TIME` | > 300 seconds | 5 |
| `oplog_window` | `REPLICATION_OPLOG_WINDOW_RUNNING_OUT` | < 1 hour | 0 |
| `cpu_normalized` | `NORMALIZED_SYSTEM_CPU_USER` | > 90 % | 10 |
| `cpu_iowait` | `SYSTEM_NORMALIZED_CPU_IOWAIT` | > 30 % | 10 |
| `backup_snapshot_failed` | `CPS_SNAPSHOT_FAILED` | a cloud backup snapshot failed | 0 |
| `backup_snapshot_behind` | `CPS_SNAPSHOT_BEHIND` | a scheduled snapshot is late | 0 |

`PRIMARY_ELECTED` and `HOST_DOWN` also fire during the project's scheduled maintenance,
when Atlas restarts members one at a time. Expect them in that window.

Disk IOPS is not a default: the right threshold depends on each cluster's provisioned
IOPS. Add it per project with `alerts` (see below).

## Usage

```hcl
module "atlas_alerts" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-mongodbatlas-alerts/v0.1.0"

  project_name     = "example-project"
  opsgenie_api_key = var.opsgenie_api_key # read from a secret store, never committed
  opsgenie_region  = "EU"

  alerts = {
    # Same key as a default: replaces it.
    disk_space_used = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      metric_threshold = {
        metric_name = "DISK_PARTITION_SPACE_USED_DATA"
        operator    = "GREATER_THAN"
        threshold   = 80
      }
    }
    # New key: added. 90 % of a cluster provisioned at 3000 IOPS.
    disk_iops = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
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

The provider reads its credentials from the environment (`MONGODB_ATLAS_PUBLIC_KEY` and
`MONGODB_ATLAS_PRIVATE_KEY`, or a service account's `MONGODB_ATLAS_CLIENT_ID` and
`MONGODB_ATLAS_CLIENT_SECRET`). Creating the integration needs the Project Owner role.

A caller that generates its own `versions.tf` over this module (for example a Terragrunt
`generate` with `if_exists = "overwrite"`) loses the `mongodb/mongodbatlas` requirement.
Terraform then resolves `hashicorp/mongodbatlas`, which does not exist. Generate the
requirement into an `*_override.tf` file instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 2.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 2.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_alert_configuration.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/alert_configuration) | resource |
| [mongodbatlas_third_party_integration.opsgenie](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/third_party_integration) | resource |
| [mongodbatlas_project.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |
| [mongodbatlas_third_party_integration.opsgenie](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/third_party_integration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alerts"></a> [alerts](#input\_alerts) | Alerts to add to the default set, keyed by a stable name. An entry with the key of a default alert replaces that default entirely. Use metric\_threshold for OUTSIDE\_METRIC\_THRESHOLD events and threshold for events with their own threshold (for example REPLICATION\_OPLOG\_WINDOW\_RUNNING\_OUT). | <pre>map(object({<br>    event_type = string<br>    enabled    = optional(bool, true)<br>    delay_min  = optional(number, 0)<br>    metric_threshold = optional(object({<br>      metric_name = string<br>      operator    = string<br>      threshold   = number<br>      units       = optional(string, "RAW")<br>      mode        = optional(string, "AVERAGE")<br>    }))<br>    threshold = optional(object({<br>      operator  = string<br>      threshold = number<br>      units     = optional(string)<br>    }))<br>    matchers = optional(list(object({<br>      field_name = string<br>      operator   = string<br>      value      = string<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_create_opsgenie_integration"></a> [create\_opsgenie\_integration](#input\_create\_opsgenie\_integration) | Create the project's Opsgenie integration. Atlas allows one Opsgenie integration per project: set false when the project already has one, and the module routes its alerts to that integration. | `bool` | `true` | no |
| <a name="input_enable_default_alerts"></a> [enable\_default\_alerts](#input\_enable\_default\_alerts) | Create the default critical alert set (see README). Set false to create only the entries in alerts. | `bool` | `true` | no |
| <a name="input_opsgenie_api_key"></a> [opsgenie\_api\_key](#input\_opsgenie\_api\_key) | API key of the Opsgenie integration that receives the alerts. Required when create\_opsgenie\_integration is true. Opsgenie sets the alert priority from this integration; Atlas sends none. | `string` | `null` | no |
| <a name="input_opsgenie_region"></a> [opsgenie\_region](#input\_opsgenie\_region) | Opsgenie region of the integration: US or EU. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Atlas project name, looked up by name, so the caller needs no dependency on the unit that creates the project. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_configuration_ids"></a> [alert\_configuration\_ids](#output\_alert\_configuration\_ids) | Atlas alert configuration ID of each alert, by key. |
| <a name="output_opsgenie_integration_id"></a> [opsgenie\_integration\_id](#output\_opsgenie\_integration\_id) | ID of the Opsgenie integration the alerts notify. |
<!-- END_TF_DOCS -->
