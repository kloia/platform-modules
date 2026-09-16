# Complete example (offline plan fixture)

Consumes the module with every resource type and a valid input set, so the
validation blocks, the connector replacement trigger and the opt-in service
execution role can be verified without a live cluster. The connector omits
`service_execution_role_arn` because `execution_role.create = true`.

```bash
terraform init -backend=false -input=false
terraform validate

# Plan shows 6 resources: the IAM role and its inline policy, the custom plugin,
# the worker configuration, the terraform_data configuration trigger, and the
# connector. Re-run after changing connector_configuration to see the connector
# planned for replacement (mitigates aws provider issue #47004).
terraform plan -input=false
```

The provider block sets `skip_credentials_validation`,
`skip_requesting_account_id` and `skip_metadata_api_check` **only** so planning
works offline. No AWS API call is made, but the provider still resolves *some*
credential source while configuring, so `terraform plan` needs placeholder
credentials present (for example `AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test`). Do not copy those flags into a deployable stack.
