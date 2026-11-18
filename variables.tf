variable "rancher_cluster_name" {
  type        = string
  description = "Name of the rancher cluster resource representing the downstream cluster. If not set, will default to `var.downstream_cluster_name`"
  default     = ""
}

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

variable "session_name" {
  description = "Session name used when assuming the role(s) for cluster access, for roles whose trust requires one. Null keeps `aws eks get-token --role-arn`, whose session name is always EKSGetTokenAuth"
  type        = string
  default     = null
}

variable "downstream_cluster_name" {
  type        = string
  description = "Name of the existing downstream cluster"
  validation {
    condition     = length(var.downstream_cluster_name) > 0
    error_message = "downstream_cluster_name cannot be an empty string"
  }
}

