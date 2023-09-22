variable "enabled" {
  type        = bool
  default     = true
  description = "Enables this vpn module"
}

variable "client_cidr" {
  type        = string
  description = "Network CIDR to use for clients"
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "Enables or disables Client VPN Cloudwatch logging."
}

variable "authentication_type" {
  type        = string
  default     = "certificate-authentication"
  description = <<-EOT
    One of `certificate-authentication` or `federated-authentication`
  EOT
  validation {
    condition     = contains(["certificate-authentication", "federated-authentication"], var.authentication_type)
    error_message = "VPN client authentication type must one be one of: certificate-authentication, federated-authentication."
  }
}

variable "saml_provider_arn" {
  default     = null
  description = "Optional SAML provider ARN. Must include this or `saml_metadata_document`"
  type        = string

  validation {
    error_message = "Invalid SAML provider ARN."

    condition = (
      var.saml_provider_arn == null ||
      try(length(regexall(
        "^arn:[^:]+:iam::(?P<account_id>\\d{12}):saml-provider\\/(?P<provider_name>[\\w+=,\\.@-]+)$",
        var.saml_provider_arn
        )) > 0,
        false
    ))
  }
}

variable "associated_subnets" {
  type        = list(string)
  description = "List of subnets to associate with the VPN endpoint"
}

variable "authorization_rules" {
  # type = list(object({
  #   name                 = string
  #   access_group_id      = string
  #   authorize_all_groups = bool
  #   description          = string
  #   target_network_cidr  = string
  # }))
  type        = list(map(any))
  description = "List of objects describing the authorization rules for the client vpn"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC to attach VPN to"
}

variable "dns_servers" {
  default = []
  type    = list(string)
  validation {
    condition = can(
      [
        for server_ip in var.dns_servers : regex(
          "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
          server_ip
        )
      ]
    )
    error_message = "IPv4 addresses must match the appropriate format xxx.xxx.xxx.xxx."
  }
  description = "Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the connecting device is used."
}

variable "split_tunnel" {
  default     = false
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}

variable "self_service_portal_enabled" {
  description = "Specify whether to enable the self-service portal for the Client VPN endpoint"
  type        = bool
  default     = false
}

variable "self_service_saml_provider_arn" {
  description = "The ARN of the IAM SAML identity provider for the self service portal if type is federated-authentication."
  type        = string
  default     = null
}

variable "session_timeout_hours" {
  description = "The maximum session duration is a trigger by which end-users are required to re-authenticate prior to establishing a VPN session. Default value is 24. Valid values: 8 | 10 | 12 | 24"
  type        = string
  default     = "24"

  validation {
    condition     = contains(["8", "10", "12", "24"], var.session_timeout_hours)
    error_message = "The maximum session duration must one be one of: 8, 10, 12, 24."
  }
}

variable "transport_protocol" {
  description = "Transport protocol used by the TLS sessions."
  type        = string
  default     = "udp"
  validation {
    condition     = contains(["udp", "tcp"], var.transport_protocol)
    error_message = "Invalid protocol type must be one of: udp, tcp."
  }
}

variable "server_cert_arn" {
  description = "Server certificate arn"
  type        = string
}

variable "root_cert_arn" {
  description = "Root certificate arn"
  type        = string
  default     = "null"
}

variable "security_group_id" {
  description = "Security group id for VPN"
  type        = string
}

variable "log_group_name" {
  description = "Log group name"
  type        = string
  default     = ""
}
