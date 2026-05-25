resource "aws_glue_catalog_database" "this" {
  count = var.create_database ? 1 : 0

  name         = var.database_name
  description  = var.database_description
  catalog_id   = var.catalog_id
  location_uri = var.database_location_uri
  parameters   = var.database_parameters

  tags = var.tags
}

resource "aws_glue_crawler" "this" {
  count = var.create_crawler ? 1 : 0

  name          = var.crawler_name
  database_name = var.create_database ? aws_glue_catalog_database.this[0].name : var.database_name
  role          = var.crawler_role_arn
  description   = var.crawler_description
  schedule      = var.crawler_schedule
  table_prefix  = var.crawler_table_prefix
  classifiers   = var.crawler_classifiers
  configuration = var.crawler_configuration

  dynamic "s3_target" {
    for_each = var.s3_targets
    content {
      path                = s3_target.value.path
      exclusions          = try(s3_target.value.exclusions, [])
      connection_name     = s3_target.value.connection_name
      event_queue_arn     = s3_target.value.event_queue_arn
      dlq_event_queue_arn = s3_target.value.dlq_event_queue_arn
      sample_size         = s3_target.value.sample_size
    }
  }

  schema_change_policy {
    update_behavior = try(var.schema_change_policy.update_behavior, "UPDATE_IN_DATABASE")
    delete_behavior = try(var.schema_change_policy.delete_behavior, "LOG")
  }

  recrawl_policy {
    recrawl_behavior = try(var.recrawl_policy.recrawl_behavior, "CRAWL_EVERYTHING")
  }

  tags = var.tags

  depends_on = [aws_glue_catalog_database.this]
}
