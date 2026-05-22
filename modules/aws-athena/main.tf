resource "aws_athena_workgroup" "this" {
  count = var.create_workgroup ? 1 : 0

  name        = var.workgroup_name
  description = var.workgroup_description
  state       = var.workgroup_state

  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query

    result_configuration {
      output_location = var.results_output_location

      dynamic "encryption_configuration" {
        for_each = var.encryption_option != null ? [1] : []
        content {
          encryption_option = var.encryption_option
          kms_key_arn       = var.kms_key_arn
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_athena_named_query" "this" {
  for_each = var.named_queries

  name        = each.key
  workgroup   = var.create_workgroup ? aws_athena_workgroup.this[0].name : var.workgroup_name
  database    = each.value.database
  query       = each.value.query
  description = try(each.value.description, null)
}
