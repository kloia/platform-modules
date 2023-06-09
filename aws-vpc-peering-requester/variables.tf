variable "requester_vpc_id" {
  description = "The ID of the requester VPC"
  type        = string
  default     = ""
}

variable "requester_vpc_cidr_block" {
  description = "The CIDR Block of the requester VPC"
  type        = string
  default     = ""
}

variable "requester_private_route_table_ids" {
  description = "Private route table IDs of requester VPC route tables"
  type = list(string)
  default = []
}

variable "requester_public_route_table_ids" {
  description = "Public route table IDs of requester VPC route tables"
  type = list(string)
  default = []
}
variable "accepter_vpc_id" {
  description = "The ID of the VPC with which you are creating the VPC Peering Connection"
  type        = string
  default     = ""
}

variable "accepter_vpc_cidr_block" {
  description = "The CIDR Block of the accepter VPC"
  type        = string
  default     = ""
}

variable "accepter_private_route_table_ids" {
  description = "Private route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}


variable "accepter_public_route_table_ids" {
  description = "Public route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}


variable "peer_owner_account_id" {
  description = "The account ID of the peer owner"
  type        = string
  default     = ""
}


variable "peer_region" {
  description = "The region of the accepter side"
  type        = string
  default     = ""
}