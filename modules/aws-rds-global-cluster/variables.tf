variable "global_cluster_identifier" {
  type        = string
  default     = ""
  description = "Global cluster identifier"
}
variable "global_cluster_engine" {
  type        = string
  default     = ""
  description = "Global cluster db engine"
}
variable "global_cluster_engine_version" {
  type        = string
  default     = ""
  description = "Global cluster db engine version"
}
variable "global_cluster_database_name" {
  type        = string
  default     = ""
  description = "Global cluster database name"
}
variable "global_cluster_storage_encrypted" {
  type        = bool
  default     = true
  description = "Global cluster storage encrypted flag"
}

variable "global_cluster_delete_protection" {
  type        = bool
  default     = true
  description = "Global cluster delete protection flag"
}

