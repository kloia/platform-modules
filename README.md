# cloudflare-zone-settings

Manages selected settings of an existing Cloudflare zone, plus Argo tiered caching and managed header transforms.
The zone is looked up by name, so the caller needs no dependency on the stack that created it.

- **Only the settings you list are managed.** Settings left out keep whatever value they have. List the settings
  that differ from Cloudflare's defaults, or that you want to pin.
- **Values** use the shape the API returns for `GET /zones/<id>/settings/<setting>`: a string for most, a list for
  `ciphers`, an object for `security_header`.
- **`settings_json` is a JSON string.** Terragrunt passes inputs as `TF_VAR_*`, and Terraform evaluates `${` and
  `%{` inside a non-string variable read from the environment; a string is taken literally.
- **Guards.** Every managed setting has `prevent_destroy` (a zone setting cannot be deleted, only changed; stop
  managing one with `terraform state rm`). The plan fails if a setting takes a value listed in
  `forbidden_setting_values` (by default `ssl = "off"` and `security_level = "essentially_off"`), or if the zone
  found by name is not the one requested.

## Usage

```hcl
module "zone_settings" {
  source = "git@github.com:kloia/platform-modules.git?ref=module/cloudflare-zone-settings/v0.1.0"

  zone_name = "example.com"
  settings_json = jsonencode({
    ssl             = "strict"
    min_tls_version = "1.2"
    security_header = {
      strict_transport_security = {
        enabled = true, max_age = 15552000, include_subdomains = false, preload = false, nosniff = false
      }
    }
  })
  argo_tiered_caching = "on"
}
```

The provider reads `CLOUDFLARE_API_TOKEN` from the environment. Token permissions: Zone: Read, Zone Settings: Edit.

## Adopting an existing zone

```hcl
import {
  to = cloudflare_zone_setting.this["ssl"]
  id = "<zone_id>/ssl"
}
import {
  to = cloudflare_argo_tiered_caching.this[0]
  id = "<zone_id>"
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `zone_name` | `string` | | Zone name |
| `settings_json` | `string` | | `jsonencode()` of setting id => value |
| `forbidden_setting_values` | `map(list(string))` | `ssl = ["off"]`, `security_level = ["essentially_off"]` | Values the plan refuses |
| `argo_tiered_caching` | `string` | `""` | `"on"`, `"off"`, or `""` to leave it alone |
| `managed_transforms` | `object` | `null` | Managed request/response header transforms; `null` leaves them alone |

## Outputs

| Name | Description |
|---|---|
| `zone_id` | Id of the zone |
| `settings` | Managed setting ids |
