output "opsgenie_integration_id" {
  description = "ID of the Opsgenie integration the alerts notify."
  value       = local.integration_id
}

output "alert_configuration_ids" {
  description = "Atlas alert configuration ID of each alert, by key."
  value       = { for k, a in mongodbatlas_alert_configuration.this : k => a.alert_configuration_id }
}
