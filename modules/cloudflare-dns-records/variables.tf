variable "zone_name" {
  description = "Cloudflare zone name. The zone id is looked up by name."
  type        = string
}

variable "records_json" {
  description = <<-EOT
    jsonencode() of a map of DNS records. Key: TYPE/name, where name is relative to the zone ("apex" for the
    zone apex), plus /<suffix> when several records share a name and type; letters, digits and _ . - only.
    Value: { content | data, proxied?, ttl?, priority?, comment?, tags?, settings?, protected?, name? }; name
    overrides the one derived from the key. Defaults: proxied false, ttl 1 (automatic), no tags.
    A JSON string because Terragrunt passes inputs as TF_VAR_* and Terraform would evaluate "$${" and "%%{"
    inside a non-string variable (SPF macros, for example).
  EOT
  type        = string

  validation {
    condition     = alltrue([for k in keys(jsondecode(var.records_json)) : can(regex("^[A-Z]+/[A-Za-z0-9_.-]+(/[A-Za-z0-9_-]+)?$", k))])
    error_message = "Record keys must look like TYPE/name or TYPE/name/<suffix> (letters, digits, _ . -)."
  }
}
