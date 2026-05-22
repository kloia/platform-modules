# aws-athena

Terraform module to create AWS Athena resources including a workgroup with configurable result location, encryption, and optional saved (named) queries.

Supported resources:

- Athena workgroup (`aws_athena_workgroup`)
- Athena named queries (`aws_athena_named_query`)

## Terraform versions

Terraform >= 1.3. Pin module version to an exact tag when referencing from Terragrunt or other modules.

## Usage

### Minimal — workgroup only

```hcl
module "athena" {
  source = "git::git@github.com:kloia/platform-modules.git//modules/aws-athena?ref=aws-athena-v0.1.0"

  workgroup_name          = "analytics"
  results_output_location = "s3://myapp-athena-results/queries/"

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Full — workgroup with encryption and named queries

```hcl
module "athena" {
  source = "git::git@github.com:kloia/platform-modules.git//modules/aws-athena?ref=aws-athena-v0.1.0"

  workgroup_name          = "analytics"
  workgroup_description   = "Workgroup for myapp analytics queries"
  results_output_location = "s3://myapp-athena-results/queries/"

  enforce_workgroup_configuration    = true
  publish_cloudwatch_metrics_enabled = true
  bytes_scanned_cutoff_per_query     = 10737418240 # 10 GB

  encryption_option = "SSE_S3"

  named_queries = {
    daily_active_users = {
      database    = "myapp_data_lake"
      description = "Count distinct active users per day"
      query       = "SELECT DATE(event_time) AS day, COUNT(DISTINCT user_id) AS dau FROM myapp_data_lake.events WHERE event_type = 'session_start' GROUP BY 1 ORDER BY 1 DESC"
    }
    revenue_by_month = {
      database    = "myapp_data_lake"
      description = "Monthly revenue summary"
      query       = "SELECT DATE_TRUNC('month', created_at) AS month, SUM(amount) AS revenue FROM myapp_data_lake.orders GROUP BY 1 ORDER BY 1 DESC"
    }
  }

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Project     = "myapp"
    Owner       = "data-platform"
  }
}
```

### Import an existing workgroup

If the workgroup already exists in AWS (e.g., the default `primary` workgroup), import it before the first apply:

```bash
terraform import module.athena.aws_athena_workgroup.this[0] <workgroup-name>
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_athena_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_athena_named_query.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_workgroup_name"></a> [workgroup\_name](#input\_workgroup\_name) | Name of the Athena workgroup. | `string` | n/a | yes |
| <a name="input_results_output_location"></a> [results\_output\_location](#input\_results\_output\_location) | S3 URL for query results (e.g., `s3://my-bucket/prefix/`). | `string` | n/a | yes |
| <a name="input_create_workgroup"></a> [create\_workgroup](#input\_create\_workgroup) | Whether to create the Athena workgroup. | `bool` | `true` | no |
| <a name="input_workgroup_description"></a> [workgroup\_description](#input\_workgroup\_description) | Description of the Athena workgroup. | `string` | `null` | no |
| <a name="input_workgroup_state"></a> [workgroup\_state](#input\_workgroup\_state) | State of the workgroup: `ENABLED` or `DISABLED`. | `string` | `"ENABLED"` | no |
| <a name="input_enforce_workgroup_configuration"></a> [enforce\_workgroup\_configuration](#input\_enforce\_workgroup\_configuration) | Enforce workgroup result location and encryption settings for all queries. | `bool` | `true` | no |
| <a name="input_publish_cloudwatch_metrics_enabled"></a> [publish\_cloudwatch\_metrics\_enabled](#input\_publish\_cloudwatch\_metrics\_enabled) | Publish workgroup-level query metrics to CloudWatch. | `bool` | `true` | no |
| <a name="input_bytes_scanned_cutoff_per_query"></a> [bytes\_scanned\_cutoff\_per\_query](#input\_bytes\_scanned\_cutoff\_per\_query) | Maximum bytes scanned per query. Queries exceeding this are cancelled. `null` disables the limit. | `number` | `null` | no |
| <a name="input_encryption_option"></a> [encryption\_option](#input\_encryption\_option) | Encryption option for query results: `SSE_S3`, `SSE_KMS`, or `CSE_KMS`. `null` disables encryption configuration. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN. Required when `encryption_option` is `SSE_KMS` or `CSE_KMS`. | `string` | `null` | no |
| <a name="input_named_queries"></a> [named\_queries](#input\_named\_queries) | Map of named (saved) Athena queries. Key is the query name. Each value: `database` (string), `query` (string), `description` (optional string). | `map(object({...}))` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workgroup_id"></a> [workgroup\_id](#output\_workgroup\_id) | ID of the Athena workgroup. |
| <a name="output_workgroup_arn"></a> [workgroup\_arn](#output\_workgroup\_arn) | ARN of the Athena workgroup. |
| <a name="output_workgroup_name"></a> [workgroup\_name](#output\_workgroup\_name) | Name of the Athena workgroup. |
| <a name="output_named_query_ids"></a> [named\_query\_ids](#output\_named\_query\_ids) | Map of named query name to its ID. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
