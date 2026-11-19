# cloudflare-rulesets

Manages the zone entry-point rulesets of an existing Cloudflare zone: WAF custom rules, managed WAF, rate limiting,
configuration rules, transform rules and any other zone phase. The zone is looked up by name.

- **The module owns every phase it lists.** Cloudflare has one entry-point ruleset per phase and zone; a rule added
  outside Terraform to a listed phase is removed by the next apply. Phases that are not listed are left alone.
- **Rules** use the `cloudflare_ruleset` `rules` shape. Keep each rule's `ref`: it is the rule's stable identity,
  and a rule without one is recreated with a new id. Provider defaults (`enabled = true`, logging enabled) need not
  be written.
- **Do not put secrets in rules.** A header value set by a transform rule, for example, is stored in state and
  shown in every plan. Keep such a phase out of the map.
- **`rulesets_json` is a JSON string.** Terragrunt passes inputs as `TF_VAR_*`, and Terraform evaluates `${` and
  `%{` inside a non-string variable read from the environment (a redirect target with `${1}` would break).
- **Guards.** Every ruleset has `prevent_destroy`: hand a phase back to the dashboard with `terraform state rm`,
  never by deleting it here. The plan fails if a phase is left with no rules, if `http_request_firewall_managed`
  has no enabled `execute` rule left, or if the zone found by name is not the one requested.

## Usage

```hcl
module "rulesets" {
  source = "git@github.com:kloia/platform-modules.git?ref=module/cloudflare-rulesets/v0.1.0"

  zone_name = "example.com"
  rulesets_json = jsonencode({
    http_request_firewall_custom = {
      name = "default"
      rules = [{
        ref         = "block-admin"
        description = "Block /admin from outside the office"
        expression  = "(http.request.uri.path wildcard \"/admin*\" and not ip.src in {192.0.2.0/24})"
        action      = "block"
      }]
    }
    http_config_settings = {
      name = "default"
      rules = [{
        ref         = "api-full-strict"
        description = "Full (strict) for the API host"
        expression  = "(http.host eq \"api.example.com\")"
        action      = "set_config"
        action_parameters = { ssl = "strict" }
      }]
    }
  })
}
```

The provider reads `CLOUDFLARE_API_TOKEN` from the environment. Token permissions: Zone: Read, plus Edit for the
phases you manage (Zone WAF, Config Rules, Transform Rules, ...).

## Adopting an existing zone

```hcl
import {
  to = cloudflare_ruleset.this["http_request_firewall_custom"]
  id = "zones/<zone_id>/<ruleset_id>"
}
```

`GET /zones/<zone_id>/rulesets` lists the entry-point rulesets and their phases.

## Inputs

| Name | Type | Description |
|---|---|---|
| `zone_name` | `string` | Zone name |
| `rulesets_json` | `string` | `jsonencode()` of phase => `{ name, description?, rules }` |

## Outputs

| Name | Description |
|---|---|
| `zone_id` | Id of the zone |
| `ruleset_ids` | Phase => entry-point ruleset id |
