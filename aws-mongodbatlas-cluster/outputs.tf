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

output "mongo_uri_srv_private" {
  value       = mongodbatlas_cluster.cluster.connection_strings[0].private_srv
  description = "Private SRV connection string for the cluster"
}

output "mongo_uri_private" {
  value       = mongodbatlas_cluster.cluster.connection_strings[0].private
  description = "Private connection string for the cluster"
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
  value = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
}

output "mongodbatlas_aws_containers"{
  value = try(local.network_containers,{})
}

output "vpc_peering_info_primary" {
  value = [ 
    for k, v  in local.network_containers :
    {
      requester_cidr = v.atlas_cidr_block
      peer_id = length([ for p in mongodbatlas_network_peering.mongo_peer : p.connection_id if p.container_id == v.id && p.accepter_region_name == var.region]) > 0 ? element([ for p in mongodbatlas_network_peering.mongo_peer : p.connection_id if p.container_id == v.id && p.accepter_region_name == var.region],0) : ""
    }
    if k == var.region
]
  description = "Mongoatlas VPC Peering Info to AWS Primary Region"
}

output "vpc_peering_info_secondary" {
  value = [
    for k, v  in local.network_containers :  
    {
      requester_cidr = v.atlas_cidr_block
      peer_id = length([ for p in mongodbatlas_network_peering.mongo_peer : p.connection_id if p.container_id == v.id && p.accepter_region_name != var.region]) > 0 ? element([ for p in mongodbatlas_network_peering.mongo_peer : p.connection_id if p.container_id == v.id && p.accepter_region_name != var.region],0) : ""
    }
    if k != var.region
    ]
  description = "Mongoatlas VPC Peering Info to AWS Primary Region"
}

output "vpc_peering_ids_primary" {
  value = [
      for p in mongodbatlas_network_peering.mongo_peer: p.connection_id
      if p.accepter_region_name == var.region
      ]
  description = "Mongoatlas VPC Peering IDs for AWS primary region"
}

output "vpc_peering_ids_secondary" {
  value = [
      for p in mongodbatlas_network_peering.mongo_peer: p.connection_id
      if p.accepter_region_name != var.region
      ]
  description = "Mongoatlas VPC Peering IDs for AWS primary region"
}
