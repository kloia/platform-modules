variable "peer_routes" {
    description = "(Required) IPv4 or IPv6 RFC1924 CIDR used for destination matches. Routing decisions are based on the most specific match.."
    type        = list(string)
    default     = []
}

variable "peer_attachment_id" {
    description = "(Optional) Identifier of EC2 Transit Gateway Attachment (required if blackhole is set to false)."
    type        = string
    default     = ""
}

variable "blackhole" {
    description = "(Optional) Indicates whether to drop traffic that matches this route (default to false)"
    type        = bool
    default     = false
}

variable "transit_gateway_route_table_id" {
    description = " (Required) Identifier of EC2 Transit Gateway Route Table."
    type        = string
}