output "alert_configuration_ids" {
  description = "Atlas alert configuration ID of each alert, by key."
  value       = { for k, a in mongodbatlas_alert_configuration.this : k => a.alert_configuration_id }
}
