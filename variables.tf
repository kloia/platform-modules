variable "rancher_agent_already_installed" {
  type        = bool
  description = "Set if downstream cluster already has the Rancher Agent installed. This injects a few env vars to the agent deployment that Rancher injects in first time agent installations, but never afterwards."
  default     = false
}

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
    error_message = "cannot be an empty string"
  }
}

variable "upstream_cluster_endpoint_ssm_key" {
  description = "SSM Key pointing to the endpoint of the upstream cluster"
  type        = string
  validation {
    condition     = length(var.upstream_cluster_endpoint_ssm_key) > 0
    error_message = "cannot be an empty string"
  }
}

variable "upstream_cluster_ca_cert_ssm_key" {
  description = "SSM Key pointing to the CA of the upstream cluster"
  type        = string
  validation {
    condition     = length(var.upstream_cluster_ca_cert_ssm_key) > 0
    error_message = "cannot be an empty string"
  }
}

variable "upstream_assume_role_arn" {
  description = "Assume role arn for upstream cluster access"
  type        = string
  validation {
    condition     = length(var.upstream_assume_role_arn) > 0
    error_message = "cannot be an empty string"
  }
}

variable "downstream_cluster_name" {
  type        = string
  description = "Name of the existing downstream cluster"
  validation {
    condition     = length(var.downstream_cluster_name) > 0
    error_message = "downstream_cluster_name cannot be an empty string"
  }
}

variable "downstream_cluster_endpoint" {
  description = "Endpoint of the downstream cluster"
  type        = string
}

variable "downstream_cluster_ca_cert" {
  description = "Certificate Authority of the downstream cluster"
  type        = string
}

variable "downstream_assume_role_arn" {
  description = "Assume role arn for downstream cluster access"
  type        = string
}
