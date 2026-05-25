output "database_name" {
  description = "Name of the Glue catalog database."
  value       = var.create_database ? aws_glue_catalog_database.this[0].name : var.database_name
}

output "database_id" {
  description = "ID of the Glue catalog database (catalog_id:name)."
  value       = var.create_database ? aws_glue_catalog_database.this[0].id : null
}

output "crawler_id" {
  description = "ID of the Glue crawler (same as its name)."
  value       = var.create_crawler ? aws_glue_crawler.this[0].id : null
}

output "crawler_arn" {
  description = "ARN of the Glue crawler."
  value       = var.create_crawler ? aws_glue_crawler.this[0].arn : null
}

output "crawler_name" {
  description = "Name of the Glue crawler."
  value       = var.create_crawler ? aws_glue_crawler.this[0].id : null
}
