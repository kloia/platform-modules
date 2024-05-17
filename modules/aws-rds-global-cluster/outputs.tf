output "database_name" {
  value       = aws_rds_global_cluster.this.database_name
  description = "Global cluster database name"
}
output "engine" {
  value       = aws_rds_global_cluster.this.engine
  description = "Global cluster database engine"
}
output "engine_version" {
  value       = aws_rds_global_cluster.this.engine_version
  description = "Global cluster database engine version"
}
output "global_cluster_identifier" {
  value       = aws_rds_global_cluster.this.id
  description = "Global cluster ID"
}
