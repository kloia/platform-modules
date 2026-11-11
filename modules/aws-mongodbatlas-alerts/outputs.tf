output "alert_configuration_ids" {
  description = "Atlas alert configuration ID of each alert, by key."
  value       = { for k, a in mongodbatlas_alert_configuration.this : k => a.alert_configuration_id }
}

output "opsgenie_integration_id" {
  description = "ID of the project's Opsgenie integration the alerts notify, or null when no tier uses Opsgenie."
  value       = local.uses_opsgenie ? local.opsgenie_integration_id : null
}

output "webhook_integration_id" {
  description = "ID of the project's webhook integration the alerts notify, or null when no tier uses a webhook."
  value       = local.uses_webhook ? local.webhook_integration_id : null
}
