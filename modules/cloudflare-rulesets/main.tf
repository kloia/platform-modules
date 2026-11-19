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
  rulesets = jsondecode(var.rulesets_json)
}

resource "cloudflare_ruleset" "this" {
  for_each = toset(keys(local.rulesets))

  zone_id     = data.cloudflare_zone.this.zone_id
  kind        = "zone"
  phase       = each.key
  name        = local.rulesets[each.key].name
  description = try(local.rulesets[each.key].description, null)
  rules       = local.rulesets[each.key].rules

  lifecycle {
    # Deleting an entry-point ruleset drops a whole phase at once. Hand a phase back to the dashboard with
    # `terraform state rm`, never by deleting it here.
    prevent_destroy = true

    # Emptying a phase is a deletion in disguise.
    precondition {
      condition     = length(local.rulesets[each.key].rules) > 0
      error_message = "A managed phase must keep at least one rule; remove the phase from state to stop managing it."
    }

    # The managed WAF phase must keep executing at least one managed ruleset.
    precondition {
      condition = each.key != "http_request_firewall_managed" || length([
        for r in local.rulesets[each.key].rules : r if r.action == "execute" && try(r.enabled, true)
      ]) > 0
      error_message = "http_request_firewall_managed must keep at least one enabled execute rule."
    }
  }
}
