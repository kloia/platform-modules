output "database_name" {
  description = "Name of the Glue catalog database."
  value       = var.create_database ? module.glue_catalog_database.name : var.database_name
}

output "database_id" {
  description = "ID of the Glue catalog database (catalog_id:name)."
  value       = var.create_database ? module.glue_catalog_database.id : null
}

output "crawler_id" {
  description = "ID of the Glue crawler (same as its name)."
  value       = var.create_crawler ? module.glue_crawler.id : null
}

output "crawler_arn" {
  description = "ARN of the Glue crawler."
  value       = var.create_crawler ? module.glue_crawler.arn : null
}

output "crawler_name" {
  description = "Name of the Glue crawler."
  value       = var.create_crawler ? module.glue_crawler.name : null
}
