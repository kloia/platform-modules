output "zone_id" {
  description = "Id of the zone."
  value       = data.cloudflare_zone.this.zone_id
}

output "ruleset_ids" {
  description = "Phase => entry-point ruleset id."
  value       = { for ph, r in cloudflare_ruleset.this : ph => r.id }
}
