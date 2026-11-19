output "zone_id" {
  description = "Id of the zone."
  value       = data.cloudflare_zone.this.zone_id
}

output "settings" {
  description = "Managed setting ids."
  value       = keys(cloudflare_zone_setting.this)
}
