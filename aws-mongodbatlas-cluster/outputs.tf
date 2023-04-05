output "cluster_id" {
  value       = mongodbatlas_cluster.cluster.cluster_id
  description = "The cluster ID"
}

output "mongo_db_version" {
  value       = mongodbatlas_cluster.cluster.mongo_db_version
  description = "Version of MongoDB the cluster runs, in major-version.minor-version format"
}

output "mongo_uri" {
  value       = mongodbatlas_cluster.cluster.mongo_uri
  description = "Base connection string for the cluster"
}

output "mongo_uri_updated" {
  value       = mongodbatlas_cluster.cluster.mongo_uri_updated
  description = "Lists when the connection string was last updated"
}

output "mongo_uri_with_options" {
  value       = mongodbatlas_cluster.cluster.mongo_uri_with_options
  description = "connection string for connecting to the Atlas cluster. Includes the replicaSet, ssl, and authSource query parameters in the connection string with values appropriate for the cluster"
}

output "connection_strings" {
  value       = mongodbatlas_cluster.cluster.connection_strings
  description = "Set of connection strings that your applications use to connect to this cluster"
}

output "container_id" {
  value       = mongodbatlas_cluster.cluster.container_id
  description = "The Network Peering Container ID"
}

output "paused" {
  value       = mongodbatlas_cluster.cluster.paused
  description = "Flag that indicates whether the cluster is paused or not"
}

output "srv_address" {
  value       = mongodbatlas_cluster.cluster.srv_address
  description = "Connection string for connecting to the Atlas cluster. The +srv modifier forces the connection to use TLS/SSL"
}

output "state_name" {
  value       = mongodbatlas_cluster.cluster.state_name
  description = "Current state of the cluster"
}


output "vpc_peering_ids" {
  value = {
    for key, value in mongodbatlas_network_peering.mongo_peer : key => value.connection_id
  }
  description = "Mongoatlas VPC Peering IDs"
}


output "database_admin_username" {
  description = "Database Admin username"
  value = mongodbatlas_database_user.admin.username
  
}

output "database_admin_password" {
  description = "Database Admin password"
  value = random_password.password.result
  sensitive = true
  
}

output "cluster_name" {
  description = "Mongo Atlas cluster name"
  value = var.cluster_name
  
}

output "project_id"{
  description = "Mongoatlas project ID"
  value = data.mongodbatlas_project.project.id
}

output "mongodbatlas_aws_containers"{
  value = try(local.network_containers,{})
}

