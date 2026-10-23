# aws-mongodbatlas-maintenance-window

Sets the maintenance window of an existing MongoDB Atlas project. The project is looked up
by name, so the caller needs no dependency on the stack that created it.

- `day_of_week`: 1 = Sunday, 2 = Monday, ... 7 = Saturday.
- `hour_of_day`: 0-23, in the **project's time zone**. Atlas does not use UTC here. A
  project with no time zone set (Project Settings) runs in UTC. Check it before you pick
  the hour.
- The window has a start but no end time, and maintenance can run longer than an hour.
- `protected_hours`: set it to the live value. If you leave it out, protected hours
  already configured in the UI may be cleared.
- `auto_defer_once_enabled`: null leaves the Atlas setting unmanaged.

## Usage

```hcl
module "atlas_maintenance_window" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-mongodbatlas-maintenance-window/v0.1.0"

  project_name = "example-project"
  day_of_week  = 1 # Sunday
  hour_of_day  = 0 # project time zone

  protected_hours = {
    start_hour_of_day = 4
    end_hour_of_day   = 17
  }
}
```

The provider reads its API key from `MONGODB_ATLAS_PUBLIC_KEY` and
`MONGODB_ATLAS_PRIVATE_KEY`. Applying needs the Project Owner role.

A caller that generates its own `versions.tf` over this module (for example a Terragrunt
`generate` with `if_exists = "overwrite"`) loses the `mongodb/mongodbatlas` requirement.
Terraform then resolves `hashicorp/mongodbatlas`, which does not exist. Generate the
requirement into an `*_override.tf` file instead: it merges into the generated block, and a
module accepts only one `required_providers` block per `terraform` block.
