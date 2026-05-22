# aws-glue

Terraform module to create AWS Glue Data Catalog resources including a Glue catalog database and S3-backed crawler.

Uses [`terraform-aws-modules/glue/aws`](https://registry.terraform.io/modules/terraform-aws-modules/glue/aws) submodules under the hood. Both the database and crawler can be toggled independently via `create_database` and `create_crawler`.

Supported resources:

- Glue catalog database (`aws_glue_catalog_database`)
- Glue crawler with S3 targets (`aws_glue_crawler`)

## Terraform versions

Terraform >= 1.3. Pin module version to an exact tag when referencing from Terragrunt or other modules.

## Usage

### Minimal — database only

```hcl
module "glue" {
  source = "git::git@github.com:kloia/platform-modules.git//modules/aws-glue?ref=aws-glue-v0.1.0"

  database_name = "my_data_lake"

  create_crawler = false

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Full — database + crawler with multiple S3 targets

```hcl
module "glue" {
  source = "git::git@github.com:kloia/platform-modules.git//modules/aws-glue?ref=aws-glue-v0.1.0"

  database_name        = "myapp_data_lake"
  database_description = "Data lake for myapp analytics"

  crawler_name        = "myapp-s3-crawler"
  crawler_role_arn    = aws_iam_role.glue.arn
  crawler_description = "Crawls Parquet files in the data lake bucket"

  s3_targets = [
    { path = "s3://myapp-data-lake/events/" },
    { path = "s3://myapp-data-lake/users/", exclusions = ["tmp/*"] },
    { path = "s3://myapp-data-lake/orders/" },
  ]

  schema_change_policy = {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }

  crawler_configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Project     = "myapp"
    Owner       = "data-platform"
  }
}
```

### Crawler against an existing database (created outside this module)

```hcl
module "glue" {
  source = "git::git@github.com:kloia/platform-modules.git//modules/aws-glue?ref=aws-glue-v0.1.0"

  database_name   = "existing_db"
  create_database = false

  crawler_name     = "my-crawler"
  crawler_role_arn = aws_iam_role.glue.arn

  s3_targets = [{ path = "s3://my-bucket/data/" }]

  tags = { Environment = "staging" }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers directly. Resources are managed by the `terraform-aws-modules/glue/aws` submodules.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_glue_catalog_database"></a> [glue\_catalog\_database](#module\_glue\_catalog\_database) | terraform-aws-modules/glue/aws//modules/catalog-database | ~> 1.0 |
| <a name="module_glue_crawler"></a> [glue\_crawler](#module\_glue\_crawler) | terraform-aws-modules/glue/aws//modules/crawler | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_catalog_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the Glue catalog database. | `string` | n/a | yes |
| <a name="input_create_database"></a> [create\_database](#input\_create\_database) | Whether to create the Glue catalog database. | `bool` | `true` | no |
| <a name="input_database_description"></a> [database\_description](#input\_database\_description) | Description of the Glue catalog database. | `string` | `null` | no |
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | AWS account ID of the Glue data catalog. Defaults to the current account. | `string` | `null` | no |
| <a name="input_database_location_uri"></a> [database\_location\_uri](#input\_database\_location\_uri) | Location of the database (e.g., an HDFS path). | `string` | `null` | no |
| <a name="input_database_parameters"></a> [database\_parameters](#input\_database\_parameters) | Additional parameters for the Glue catalog database. | `map(string)` | `{}` | no |
| <a name="input_create_crawler"></a> [create\_crawler](#input\_create\_crawler) | Whether to create the Glue crawler. | `bool` | `true` | no |
| <a name="input_crawler_name"></a> [crawler\_name](#input\_crawler\_name) | Name of the Glue crawler. | `string` | `null` | no |
| <a name="input_crawler_role_arn"></a> [crawler\_role\_arn](#input\_crawler\_role\_arn) | IAM role ARN that the crawler uses to access S3 and Glue. | `string` | `null` | no |
| <a name="input_crawler_description"></a> [crawler\_description](#input\_crawler\_description) | Description of the Glue crawler. | `string` | `null` | no |
| <a name="input_crawler_schedule"></a> [crawler\_schedule](#input\_crawler\_schedule) | Cron expression for the crawler schedule (e.g., `cron(0 12 * * ? *)`). Omit for on-demand. | `string` | `null` | no |
| <a name="input_crawler_table_prefix"></a> [crawler\_table\_prefix](#input\_crawler\_table\_prefix) | Prefix for table names created by the crawler. | `string` | `null` | no |
| <a name="input_crawler_classifiers"></a> [crawler\_classifiers](#input\_crawler\_classifiers) | List of custom classifier names to associate with the crawler. | `list(string)` | `[]` | no |
| <a name="input_crawler_configuration"></a> [crawler\_configuration](#input\_crawler\_configuration) | JSON string of Glue crawler configuration (e.g., grouping behavior). | `string` | `null` | no |
| <a name="input_s3_targets"></a> [s3\_targets](#input\_s3\_targets) | List of S3 target configurations for the crawler. Each object: `path` (required), `exclusions`, `connection_name`, `event_queue_arn`, `dlq_event_queue_arn`, `sample_size`. | `list(object({...}))` | `[]` | no |
| <a name="input_schema_change_policy"></a> [schema\_change\_policy](#input\_schema\_change\_policy) | Behavior when the crawler discovers a changed schema. `update_behavior`: UPDATE\_IN\_DATABASE or LOG. `delete_behavior`: DELETE\_FROM\_DATABASE, LOG, or DEPRECATE\_IN\_DATABASE. | `object({...})` | `{}` | no |
| <a name="input_recrawl_policy"></a> [recrawl\_policy](#input\_recrawl\_policy) | Recrawl behavior. `recrawl_behavior`: CRAWL\_EVERYTHING, CRAWL\_NEW\_FOLDERS\_ONLY, or CRAWL\_EVENT\_MODE. | `object({...})` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the Glue catalog database. |
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | ID of the Glue catalog database (`catalog_id:name`). |
| <a name="output_crawler_id"></a> [crawler\_id](#output\_crawler\_id) | ID of the Glue crawler (same as its name). |
| <a name="output_crawler_arn"></a> [crawler\_arn](#output\_crawler\_arn) | ARN of the Glue crawler. |
| <a name="output_crawler_name"></a> [crawler\_name](#output\_crawler\_name) | Name of the Glue crawler. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
