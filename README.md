# AWS Athena Terraform Module

Terraform module which creates AWS Athena Workgroup and Named Query resources.

## Usage

### Basic Workgroup

```hcl
module "athena" {
  source = "git::https://github.com/kloia/platform-modules//aws-athena?ref=main"

  workgroup_name          = "my-workgroup"
  results_output_location = "s3://my-query-results-bucket/athena/"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Workgroup with SSE-S3 Encryption and Cost Control

```hcl
module "athena" {
  source = "git::https://github.com/kloia/platform-modules//aws-athena?ref=main"

  workgroup_name          = "analytics-workgroup"
  workgroup_description   = "Workgroup for the analytics team"
  results_output_location = "s3://my-query-results-bucket/analytics/"

  enforce_workgroup_configuration    = true
  publish_cloudwatch_metrics_enabled = true
  bytes_scanned_cutoff_per_query     = 1073741824 # 1 GB

  encryption_option = "SSE_S3"

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Workgroup with KMS Encryption and Named Queries

```hcl
module "athena" {
  source = "git::https://github.com/kloia/platform-modules//aws-athena?ref=main"

  workgroup_name          = "secure-workgroup"
  results_output_location = "s3://my-secure-results-bucket/athena/"

  encryption_option = "SSE_KMS"
  kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"

  named_queries = {
    daily_summary = {
      database    = "my_database"
      query       = "SELECT date, COUNT(*) AS events FROM events WHERE date = current_date GROUP BY date;"
      description = "Daily event count summary"
    }
    top_users = {
      database = "my_database"
      query    = "SELECT user_id, COUNT(*) AS actions FROM events GROUP BY user_id ORDER BY actions DESC LIMIT 100;"
    }
  }

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Named Queries Against an Existing Workgroup

```hcl
module "athena" {
  source = "git::https://github.com/kloia/platform-modules//aws-athena?ref=main"

  create_workgroup        = false
  workgroup_name          = "existing-workgroup"
  results_output_location = "s3://my-bucket/results/"

  named_queries = {
    weekly_report = {
      database = "reporting"
      query    = "SELECT * FROM weekly_aggregates WHERE week = date_trunc('week', current_date);"
    }
  }

  tags = {
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `workgroup_name` | Name of the Athena workgroup | `string` | — | yes |
| `results_output_location` | S3 URL for query results (e.g., `s3://my-bucket/prefix/`) | `string` | — | yes |
| `create_workgroup` | Whether to create the Athena workgroup | `bool` | `true` | no |
| `workgroup_description` | Description of the Athena workgroup | `string` | `null` | no |
| `workgroup_state` | State of the workgroup: `ENABLED` or `DISABLED` | `string` | `"ENABLED"` | no |
| `enforce_workgroup_configuration` | Enforce workgroup result location and encryption for all queries | `bool` | `true` | no |
| `publish_cloudwatch_metrics_enabled` | Publish workgroup-level query metrics to CloudWatch | `bool` | `true` | no |
| `bytes_scanned_cutoff_per_query` | Maximum bytes scanned per query. `null` disables the limit | `number` | `null` | no |
| `encryption_option` | Encryption option for results: `SSE_S3`, `SSE_KMS`, `CSE_KMS`, or `null` | `string` | `null` | no |
| `kms_key_arn` | KMS key ARN for `SSE_KMS` or `CSE_KMS` encryption | `string` | `null` | no |
| `named_queries` | Map of named Athena queries. Key is the query name | `map(object)` | `{}` | no |
| `tags` | Map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `workgroup_id` | ID of the Athena workgroup |
| `workgroup_arn` | ARN of the Athena workgroup |
| `workgroup_name` | Name of the Athena workgroup |
| `named_query_ids` | Map of named query name to its ID |
