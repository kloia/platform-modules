data "cloudflare_zone" "this" {
  filter = { name = var.zone_name }

  lifecycle {
    postcondition {
      condition     = self.name == var.zone_name
      error_message = "The zone found by name is not the zone requested."
    }
  }
}

locals {
  settings = jsondecode(var.settings_json)
}

resource "cloudflare_zone_setting" "this" {
  for_each = toset(keys(local.settings))

  zone_id    = data.cloudflare_zone.this.zone_id
  setting_id = each.key
  value      = local.settings[each.key]

  lifecycle {
    # A zone setting cannot be deleted, only changed. Stop managing one with `terraform state rm`.
    prevent_destroy = true

    precondition {
      condition     = !contains(lookup(var.forbidden_setting_values, each.key, []), try(tostring(local.settings[each.key]), ""))
      error_message = "This value switches a zone-wide protection off (see forbidden_setting_values)."
    }
  }
}

resource "cloudflare_argo_tiered_caching" "this" {
  count = var.argo_tiered_caching == "" ? 0 : 1

  zone_id = data.cloudflare_zone.this.zone_id
  value   = var.argo_tiered_caching

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_managed_transforms" "this" {
  count = var.managed_transforms == null ? 0 : 1

  zone_id                  = data.cloudflare_zone.this.zone_id
  managed_request_headers  = var.managed_transforms.managed_request_headers
  managed_response_headers = var.managed_transforms.managed_response_headers

  lifecycle {
    prevent_destroy = true
  }
}
