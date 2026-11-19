variable "zone_name" {
  description = "Cloudflare zone name. The zone id is looked up by name."
  type        = string
}

variable "rulesets_json" {
  description = <<-EOT
    jsonencode() of the zone entry-point rulesets keyed by phase: { name, description?, rules = [...] }, each rule
    in the cloudflare_ruleset `rules` shape (keep `ref`, it is the rule's stable identity). The module owns every
    listed phase: a rule added outside Terraform to such a phase is removed by the next apply. Unlisted phases
    are left alone.
    A JSON string because Terragrunt passes inputs as TF_VAR_* and Terraform would evaluate "$${" and "%%{"
    inside a non-string variable (redirect targets, for example).
  EOT
  type        = string
}
