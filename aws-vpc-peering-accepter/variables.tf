variable "vpc_peer_id" {
  description = "VPC peering connection ID"
  type = string
  default = ""
}

variable "vpc_peer_ids" {
  description = "VPC peering connections IDs for batch operations"
  type = list(string)
  default = []

}

variable "accepter_all_private_route_table_ids"{
  description = "All private route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "requester_vpc_cidr_block" {
  description = "The CIDR Block of the requester VPC"
  type        = string
  default     = ""
}

variable "accepter_private_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "accepter_public_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "tags"{
  description = "Tags for the peering connection"
  default = {}
  type = map(string)
}

variable "requester_peer_info"{
  description = "Tags for the peering connection"
  default = []
  type = list(object({
    requester_cidr = string
    peer_id = string
  }))
}
