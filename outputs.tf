output "workgroup_id" {
  description = "ID of the Athena workgroup."
  value       = var.create_workgroup ? aws_athena_workgroup.this[0].id : null
}

output "workgroup_arn" {
  description = "ARN of the Athena workgroup."
  value       = var.create_workgroup ? aws_athena_workgroup.this[0].arn : null
}

output "workgroup_name" {
  description = "Name of the Athena workgroup."
  value       = var.create_workgroup ? aws_athena_workgroup.this[0].name : var.workgroup_name
}

output "named_query_ids" {
  description = "Map of named query name to its ID."
  value       = { for k, v in aws_athena_named_query.this : k => v.id }
}
