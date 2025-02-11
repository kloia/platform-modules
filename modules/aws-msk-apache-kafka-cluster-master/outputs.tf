output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = join("", aws_msk_cluster.default[*].arn)
}

output "bootstrap_brokers" {
  description = "A comma separated list of one or more hostname:port pairs of kafka brokers suitable to boostrap connectivity to the kafka cluster"
  value       = join(",", aws_msk_cluster.default[*].bootstrap_brokers)
}

output "bootstrap_brokers_tls" {
  description = "A comma separated list of one or more DNS names (or IPs) and TLS port pairs kafka brokers suitable to boostrap connectivity to the kafka cluster"
  value       = join(",", aws_msk_cluster.default[*].bootstrap_brokers_tls)
}

output "bootstrap_brokers_scram" {
  description = "A comma separated list of one or more DNS names (or IPs) and TLS port pairs kafka brokers suitable to boostrap connectivity using SASL/SCRAM to the kafka cluster."
  value       = join(",", aws_msk_cluster.default[*].bootstrap_brokers_sasl_scram)
}

output "bootstrap_brokers_iam" {
  description = "A comma separated list of one or more DNS names (or IPs) and TLS port pairs kafka brokers suitable to boostrap connectivity using SASL/IAM to the kafka cluster."
  value       = join(",", aws_msk_cluster.default[*].bootstrap_brokers_sasl_iam)
}

output "all_brokers" {
  description = "A list of all brokers"
  value       = local.brokers
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates"
  value       = join("", aws_msk_cluster.default[*].current_version)
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = join(",", aws_msk_cluster.default[*].zookeeper_connect_string)
}

output "config_arn" {
  description = "Amazon Resource Name (ARN) of the configuration"
  value       = join("", aws_msk_configuration.config[*].arn)
}

output "latest_revision" {
  description = "Latest revision of the configuration"
  value       = join("", aws_msk_configuration.config[*].latest_revision)
}

output "cluster_name" {
  description = "MSK Cluster name"
  value       = join("", aws_msk_cluster.default[*].cluster_name)
}

output "bootstrap_brokers_public_sasl_scram" {
  value       = one(aws_msk_cluster.default[*].bootstrap_brokers_public_sasl_scram)
  description = "Comma separated list of one or more DNS names (or IP addresses) and SASL SCRAM port pairs for public access to the Kafka cluster using SASL/SCRAM"
}

output "username" {
  value = var.client_sasl_scram_enabled ? "msk" : null
  # this might need to change later on, currently hardcoded in the module
  description = ""
}

output "password" {
  value       =  var.client_sasl_scram_enabled ? random_password.password[0].result : null
  description = ""
}

output "cluster_uuid" {
  description = "MSK Cluster UUID"
  value       = join("", aws_msk_cluster.default[*].cluster_uuid)
}

