variable "zone_name" {
  description = "Cloudflare zone name. The zone id is looked up by name."
  type        = string
}

variable "settings_json" {
  description = <<-EOT
    jsonencode() of setting_id => value, in the shape the Cloudflare API returns
    (GET /zones/<id>/settings/<setting>). List only the settings you manage; the others are left alone.
    A JSON string because Terragrunt passes inputs as TF_VAR_* and Terraform would evaluate "$${" and "%%{"
    inside a non-string variable.
  EOT
  type        = string
}

variable "forbidden_setting_values" {
  description = "Values a setting may never take, because each one switches a protection off for the whole zone."
  type        = map(list(string))
  default = {
    ssl            = ["off"]
    security_level = ["essentially_off"]
  }
}

variable "argo_tiered_caching" {
  description = "\"on\" or \"off\" to manage Argo tiered caching, \"\" to leave it alone."
  type        = string
  default     = ""
}

variable "managed_transforms" {
  description = "Managed request/response header transforms to enable. null leaves them alone."
  type = object({
    managed_request_headers  = list(object({ id = string, enabled = bool }))
    managed_response_headers = list(object({ id = string, enabled = bool }))
  })
  default = null
}
