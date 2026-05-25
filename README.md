# AWS Glue Terraform Module

Terraform module which creates AWS Glue Catalog Database and Crawler resources.

## Usage

### Database Only

```hcl
module "glue" {
  source = "git::https://github.com/kloia/platform-modules//aws-glue?ref=main"

  database_name        = "my-data-catalog"
  database_description = "Data catalog for raw S3 data"

  create_crawler = false

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Database with S3 Crawler

```hcl
module "glue" {
  source = "git::https://github.com/kloia/platform-modules//aws-glue?ref=main"

  database_name        = "my-data-catalog"
  database_description = "Data catalog for raw S3 data"

  create_crawler    = true
  crawler_name      = "my-s3-crawler"
  crawler_role_arn  = "arn:aws:iam::123456789012:role/GlueCrawlerRole"
  crawler_schedule  = "cron(0 12 * * ? *)"
  crawler_table_prefix = "raw_"

  s3_targets = [
    {
      path       = "s3://my-data-bucket/raw/"
      exclusions = ["**.tmp"]
    }
  ]

  schema_change_policy = {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Crawler Against Existing Database

```hcl
module "glue" {
  source = "git::https://github.com/kloia/platform-modules//aws-glue?ref=main"

  create_database = false
  database_name   = "existing-catalog"

  create_crawler   = true
  crawler_name     = "incremental-crawler"
  crawler_role_arn = "arn:aws:iam::123456789012:role/GlueCrawlerRole"

  s3_targets = [
    { path = "s3://my-bucket/events/" },
    { path = "s3://my-bucket/metrics/" }
  ]

  recrawl_policy = {
    recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
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
| `database_name` | Name of the Glue catalog database | `string` | — | yes |
| `create_database` | Whether to create the Glue catalog database | `bool` | `true` | no |
| `database_description` | Description of the Glue catalog database | `string` | `null` | no |
| `catalog_id` | AWS account ID of the Glue data catalog | `string` | `null` | no |
| `database_location_uri` | Location of the database (e.g., an HDFS path) | `string` | `null` | no |
| `database_parameters` | Additional parameters for the Glue catalog database | `map(string)` | `{}` | no |
| `create_crawler` | Whether to create the Glue crawler | `bool` | `true` | no |
| `crawler_name` | Name of the Glue crawler | `string` | `null` | no |
| `crawler_role_arn` | IAM role ARN that the crawler uses to access S3 and Glue | `string` | `null` | no |
| `crawler_description` | Description of the Glue crawler | `string` | `null` | no |
| `crawler_schedule` | Cron expression for the crawler schedule. Omit for on-demand | `string` | `null` | no |
| `crawler_table_prefix` | Prefix for table names created by the crawler | `string` | `null` | no |
| `crawler_classifiers` | List of custom classifier names to associate with the crawler | `list(string)` | `[]` | no |
| `crawler_configuration` | JSON string of Glue crawler configuration | `string` | `null` | no |
| `s3_targets` | List of S3 target configurations for the crawler | `list(object)` | `[]` | no |
| `schema_change_policy` | Behavior when the crawler discovers a changed schema | `object` | `{}` | no |
| `recrawl_policy` | Recrawl behavior configuration | `object` | `{}` | no |
| `tags` | Map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `database_name` | Name of the Glue catalog database |
| `database_id` | ID of the Glue catalog database (`catalog_id:name`) |
| `crawler_id` | ID of the Glue crawler |
| `crawler_arn` | ARN of the Glue crawler |
| `crawler_name` | Name of the Glue crawler |
