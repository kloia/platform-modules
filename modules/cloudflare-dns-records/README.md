# cloudflare-dns-records

Manages the DNS records of an existing Cloudflare zone from one compact map. The zone is looked up by name.

- **Keys carry the name and type.** `TYPE/name`, where `name` is relative to the zone and `apex` is the zone
  itself, plus `/<suffix>` when several records share a name and type (any stable unique suffix). Keys use
  letters, digits and `_ . / -` only, so an address such as `cloudflare_dns_record.this["CNAME/api"]` can be
  passed to `-target`. Renaming a key deletes and recreates the record. A record literally named `apex` sets
  `name` explicitly.
- **Values are short.** `{ content | data, proxied?, ttl?, priority?, comment?, tags?, settings?, protected? }`.
  Defaults: `proxied = false` (DNS only), `ttl = 1` (automatic), no tags, no settings. `data` is for record types
  that need it (SRV, CAA, ...).
- **Protected records.** `protected = true` puts a record under `prevent_destroy` (in
  `cloudflare_dns_record.protected`): use it for NS delegations, MX, SPF/DMARC/DKIM and other records a zone cannot
  lose. Changing the flag on an existing record moves it between two resources; add a `moved` block in the same
  change, or Terraform plans a delete and a create.
- **`records_json` is a JSON string.** Terragrunt passes inputs as `TF_VAR_*`, and Terraform evaluates `${` and
  `%{` inside a non-string variable read from the environment (an SPF macro such as `%{i}` would break).

## Usage

```hcl
module "dns" {
  source = "git@github.com:kloia/platform-modules.git?ref=module/cloudflare-dns-records/v0.1.0"

  zone_name = "example.com"
  records_json = jsonencode({
    "A/apex"        = { content = "192.0.2.10", proxied = true }
    "CNAME/www"     = { content = "example.com", proxied = true }
    "CNAME/api"     = { content = "api-origin.example.net", ttl = 300, comment = "API" }
    "MX/apex/1"     = { content = "mx1.example.net", priority = 10, protected = true }
    "MX/apex/2"     = { content = "mx2.example.net", priority = 20, protected = true }
    "NS/sub/1"      = { content = "ns-1.example.org", protected = true }
    "TXT/apex"      = { content = "\"v=spf1 -all\"", protected = true }
  })
}
```

The provider reads `CLOUDFLARE_API_TOKEN` from the environment. Token permissions: Zone: Read, DNS: Edit.

To unprotect a record:

```hcl
moved {
  from = cloudflare_dns_record.protected["NS/sub/1"]
  to   = cloudflare_dns_record.this["NS/sub/1"]
}
```

## Adopting an existing zone

```hcl
import {
  to = cloudflare_dns_record.this["CNAME/api"]
  id = "<zone_id>/<record_id>"
}
```

## Inputs

| Name | Type | Description |
|---|---|---|
| `zone_name` | `string` | Zone name |
| `records_json` | `string` | `jsonencode()` of the record map described above |

## Outputs

| Name | Description |
|---|---|
| `zone_id` | Id of the zone |
| `records` | Record key => full name |
