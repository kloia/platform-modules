variable "ip_set_addresses" {
  description = "IP addresses"
  type        = list(string)
  default     = []
}

variable "ip_set_name" {
  description = "IP Set Name"
  default     = ""
}

variable "ip_set_description" {
  description = "Description of the IP set"
  default     = ""

}

variable "whitelist_scope" {
  description = ""
  default     = "REGIONAL"
}

variable "blacklist_ip_addresses" {
  description = "Blacklist IP addresses"
  type        = list(string)
  default     = []
}

variable "blacklist_ip_set_name" {
  description = "IP Set Name"
  default     = ""
}

variable "blacklist_ip_set_description" {
  description = "Description of the IP set"
  default     = ""

}

variable "blacklist_scope" {
  description = ""
  default     = "REGIONAL"
}




variable "ip_address_groups" {
  description = "Map of IP address groups for creating multiple AWS WAFv2 IP Sets"
  type = map(object({
    ip_address_version = string
    whitelist_scope    = string
    ip_set_description = string
    ip_set_name        = string
    ip_set_addresses   = list(string)
  }))
  default = {}
}
