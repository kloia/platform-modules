output "zone_id" {
  description = "Id of the zone."
  value       = data.cloudflare_zone.this.zone_id
}

output "records" {
  description = "Record key => full name."
  value       = merge({ for k, r in cloudflare_dns_record.this : k => r.name }, { for k, r in cloudflare_dns_record.protected : k => r.name })
}
