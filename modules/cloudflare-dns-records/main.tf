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
  # TYPE/name[/suffix] -> type and full name. "apex" is the zone itself.
  records = {
    for k, r in jsondecode(var.records_json) : k => merge(r, {
      type = split("/", k)[0]
      name = try(r.name, split("/", k)[1] == "apex" ? var.zone_name : "${split("/", k)[1]}.${var.zone_name}")
    })
  }
  plain     = { for k, r in local.records : k => r if !try(r.protected, false) }
  protected = { for k, r in local.records : k => r if try(r.protected, false) }
}

resource "cloudflare_dns_record" "this" {
  for_each = local.plain

  zone_id  = data.cloudflare_zone.this.zone_id
  name     = each.value.name
  type     = each.value.type
  content  = try(each.value.content, null)
  data     = try(each.value.data, null)
  proxied  = try(each.value.proxied, false)
  ttl      = try(each.value.ttl, 1)
  priority = try(each.value.priority, null)
  comment  = try(each.value.comment, null)
  tags     = try(each.value.tags, [])
  settings = try(each.value.settings, {})
}

# Records a zone cannot lose (delegations, mail). Moving a record between this resource and
# cloudflare_dns_record.this needs a `moved` block, or Terraform plans a delete and a create.
resource "cloudflare_dns_record" "protected" {
  for_each = local.protected

  zone_id  = data.cloudflare_zone.this.zone_id
  name     = each.value.name
  type     = each.value.type
  content  = try(each.value.content, null)
  data     = try(each.value.data, null)
  proxied  = try(each.value.proxied, false)
  ttl      = try(each.value.ttl, 1)
  priority = try(each.value.priority, null)
  comment  = try(each.value.comment, null)
  tags     = try(each.value.tags, [])
  settings = try(each.value.settings, {})

  lifecycle {
    prevent_destroy = true
  }
}
