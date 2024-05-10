variable "project_name" {
  description = "The name of the project you want to create"
  type        = string
}

variable "create_mongodbatlas_project" {
  type        = bool
  description = "Create mongoDB atlas project flag"
  default     = false

}

variable "org_id" {
  description = "The ID of the Atlas organization you want to create the project within"
  type        = string
}

variable "teams" {
  description = "An object that contains all the groups that should be created in the project"
  type        = map(any)
  default     = {}
}

variable "aws_kms_config" {
  description = "AWS KMS config for encrption at rest"
  type        = map(any)
  default     = {}
}

variable "white_lists_with_cidr" {
  description = "An object that contains all the network white-lists that should be created in the project"
  type        = map(any)
  default     = {}
}

variable "white_lists_with_security_group" {
  description = "An object that contains all the network white-lists that should be created in the project"
  type        = map(any)
  default     = {}
}

variable "region" {
  description = "The AWS region-name that the cluster will be deployed on"
  type        = string
}

variable "replication_specs_region_configs" {
  description = "Region configs for replication specs"
  type        = list(any)
}

variable "cluster_name" {
  description = "The cluster name"
  type        = string
}

variable "instance_type" {
  description = "The Atlas instance-type name"
  type        = string
}

variable "mongodb_major_ver" {
  description = "The MongoDB cluster major version"
  type        = number
}

variable "cluster_type" {
  description = "The MongoDB Atlas cluster type - SHARDED/REPLICASET/GEOSHARDED"
  type        = string
}

variable "num_shards" {
  description = "number of shards"
  type        = number
}

variable "cloud_backup" {
  description = "Indicating if the cluster uses Cloud Backup for backups"
  type        = bool
  default     = true
}

variable "pit_enabled" {
  description = "Indicating if the cluster uses Continuous Cloud Backup, if set to true - cloud_backup must also be set to true"
  type        = bool
  default     = false
}

variable "disk_size_gb" {
  description = "Capacity,in gigabytes,of the host’s root volume"
  type        = number
  default     = null
}

variable "auto_scaling_disk_gb_enabled" {
  description = "Indicating if disk auto-scaling is enabled"
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "STANDARD or PROVISIONED for IOPS higher than the default instance IOPS"
  type        = string
  default     = "STANDARD"
}

variable "provider_disk_iops" {
  description = "The maximum IOPS the system can perform"
  type        = number
  default     = null
}


variable "vpc_peer" {
  description = "An object that contains all VPC peering requests from the cluster to AWS VPC's"
  type        = map(any)
  default     = {}
}

variable "encryption_at_rest_provider" {
  description = "Possible values are AWS, GCP, AZURE or NONE"
  type        = string
  default     = ""
}

locals {
  cloud_provider = "AWS"
}







