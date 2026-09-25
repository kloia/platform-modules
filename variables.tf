variable "name" {
  description = "Name for the connection; prefixes the customer gateway, VPN connection, log group and alarm names."
  type        = string
}

variable "tags" {
  description = "Tags added to every resource."
  type        = map(string)
  default     = {}
}

################################################################################
# Customer gateway
################################################################################

variable "customer_gateway_ip_address" {
  description = "Public IPv4 address of the remote VPN device."
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "ASN of the remote device. AWS requires one even for static routing, where it is not negotiated."
  type        = number
  default     = 65000
}

variable "customer_gateway_device_name" {
  description = "Optional name of the remote device, for reference only."
  type        = string
  default     = null
}

################################################################################
# VPN connection
################################################################################

variable "transit_gateway_id" {
  description = "Transit gateway the VPN attaches to."
  type        = string
}

variable "static_routes_only" {
  description = "Use static routing. Set false for BGP, which also makes remote_cidrs unnecessary."
  type        = bool
  default     = true
}

variable "local_ipv4_network_cidr" {
  description = "Remote-side CIDR the tunnels carry (the IPsec traffic selector). Null means 0.0.0.0/0."
  type        = string
  default     = null
}

variable "remote_ipv4_network_cidr" {
  description = "AWS-side CIDR the tunnels carry (the IPsec traffic selector). Null means 0.0.0.0/0."
  type        = string
  default     = null
}

variable "tunnel_inside_cidrs" {
  description = "Optional inside /30s from 169.254.0.0/16, [tunnel1, tunnel2]. AWS picks them when empty."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.tunnel_inside_cidrs) == 0 || length(var.tunnel_inside_cidrs) == 2
    error_message = "tunnel_inside_cidrs takes zero or two entries."
  }
}

variable "tunnel_preshared_keys" {
  description = "Optional pre-shared keys, [tunnel1, tunnel2]. AWS generates them when empty; either way they are stored in state."
  type        = list(string)
  default     = []
  sensitive   = true

  validation {
    condition     = length(var.tunnel_preshared_keys) == 0 || length(var.tunnel_preshared_keys) == 2
    error_message = "tunnel_preshared_keys takes zero or two entries."
  }
}

variable "tunnel_options" {
  description = <<-EOT
    IKE/IPsec options applied to both tunnels. Unset keys keep the AWS defaults, which include
    weak proposals (DH group 2, SHA1); pin them to what the remote device supports.
  EOT
  type = object({
    ike_versions                 = optional(list(string))
    phase1_encryption_algorithms = optional(list(string))
    phase1_integrity_algorithms  = optional(list(string))
    phase1_dh_group_numbers      = optional(list(number))
    phase1_lifetime_seconds      = optional(number)
    phase2_encryption_algorithms = optional(list(string))
    phase2_integrity_algorithms  = optional(list(string))
    phase2_dh_group_numbers      = optional(list(number))
    phase2_lifetime_seconds      = optional(number)
    dpd_timeout_action           = optional(string)
    dpd_timeout_seconds          = optional(number)
    startup_action               = optional(string)
  })
  default = {}
}

################################################################################
# Transit gateway routing
################################################################################

variable "transit_gateway_route_table_id" {
  description = "Transit gateway route table that receives remote_cidrs, and the association/propagation when enabled."
  type        = string
}

variable "remote_cidrs" {
  description = "Remote CIDRs routed to the VPN attachment. Required for static routing."
  type        = list(string)
  default     = []
}

variable "transit_gateway_route_table_association" {
  description = "Associate the attachment with transit_gateway_route_table_id. Leave false on a transit gateway with default association enabled."
  type        = bool
  default     = false
}

variable "transit_gateway_route_table_propagation" {
  description = "Propagate the attachment into transit_gateway_route_table_id. Only BGP routes propagate."
  type        = bool
  default     = false
}

################################################################################
# Logging and alarms
################################################################################

variable "create_tunnel_log_group" {
  description = "Create a log group for tunnel IKE/IPsec logs, shared by both tunnels."
  type        = bool
  default     = true
}

variable "tunnel_log_group_arn" {
  description = "Existing log group for tunnel logs when create_tunnel_log_group is false. Null disables tunnel logging."
  type        = string
  default     = null
}

variable "tunnel_log_retention_in_days" {
  description = "Retention of the created tunnel log group."
  type        = number
  default     = 90
}

variable "tunnel_log_kms_key_id" {
  description = "Optional KMS key ARN for the created tunnel log group."
  type        = string
  default     = null
}

variable "create_tunnel_alarms" {
  description = "Create one TunnelState alarm per tunnel."
  type        = bool
  default     = true
}

variable "tunnel_alarm_actions" {
  description = "ARNs notified on ALARM and OK, usually an SNS topic."
  type        = list(string)
  default     = []
}

variable "tunnel_alarm_actions_enabled" {
  description = "Whether the alarms notify. Tunnels stay DOWN until the remote side is configured, so set false for the first apply."
  type        = bool
  default     = true
}

variable "tunnel_alarm_period" {
  description = "Seconds per evaluation period."
  type        = number
  default     = 300
}

variable "tunnel_alarm_evaluation_periods" {
  description = "Consecutive DOWN periods before the alarm fires."
  type        = number
  default     = 2
}
