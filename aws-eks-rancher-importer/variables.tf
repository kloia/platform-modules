variable "upstream_cluster_name_ssm_key" {
  type        = string
  description = "SSM Key pointing to existing upstream cluster name"
  validation {
    condition     = length(var.upstream_cluster_name_ssm_key) > 0
    error_message = "upstream_cluster_name cannot be an empty string"
  }
}

variable "upstream_cluster_endpoint_ssm_key" {
  description = "SSM Key pointing to the endpoint of the upstream cluster"
  default     = ""
  type        = string
}

variable "upstream_cluster_ca_cert_ssm_key" {
  description = "SSM Key pointing to the CA of the upstream cluster"
  default     = ""
  type        = string
}

variable "upstream_assume_role_arn" {
  description = "Assume role arn for upstream cluster access"
  type        = string
}

variable "downstream_cluster_name" {
  type        = string
  description = "Name of the existing downstream cluster"
  validation {
    condition     = length(var.downstream_cluster_name) > 0
    error_message = "downstream_cluster_name cannot be an empty string"
  }
}

