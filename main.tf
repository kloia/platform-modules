module "glue_catalog_database" {
  source  = "terraform-aws-modules/glue/aws//modules/catalog-database"
  version = "~> 1.0"

  create       = var.create_database
  name         = var.database_name
  description  = var.database_description
  catalog_id   = var.catalog_id
  location_uri = var.database_location_uri
  parameters   = var.database_parameters

  tags = var.tags
}

module "glue_crawler" {
  source  = "terraform-aws-modules/glue/aws//modules/crawler"
  version = "~> 1.0"

  create        = var.create_crawler
  name          = var.crawler_name
  database_name = var.create_database ? module.glue_catalog_database.name : var.database_name
  role          = var.crawler_role_arn
  description   = var.crawler_description
  schedule      = var.crawler_schedule
  table_prefix  = var.crawler_table_prefix
  classifiers   = var.crawler_classifiers
  configuration = var.crawler_configuration

  s3_targets           = var.s3_targets
  schema_change_policy = var.schema_change_policy
  recrawl_policy       = var.recrawl_policy

  tags = var.tags

  depends_on = [module.glue_catalog_database]
}
