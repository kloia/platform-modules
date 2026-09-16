# Complete example (offline plan fixture)

Consumes the module with every resource type and a valid input set, so the
validation blocks and the connector replacement trigger can be verified without
AWS credentials or a live cluster.

```bash
terraform init -backend=false -input=false
terraform validate

# Plan shows 4 resources: custom plugin, worker configuration, the
# terraform_data configuration trigger, and the connector. Re-run after
# changing connector_configuration to see the connector planned for replacement
# (mitigates aws provider issue #47004).
terraform plan -input=false
```

The provider block sets `skip_credentials_validation`,
`skip_requesting_account_id` and `skip_metadata_api_check` **only** so planning
works offline. Do not copy those flags into a deployable stack.
