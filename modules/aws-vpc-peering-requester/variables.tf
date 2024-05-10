variable "name" {
  description = "The Name of VPC Peering"
  type        = string
  default     = ""
}

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
  type        = list(string)
  default     = []
}

variable "requester_public_route_table_ids" {
  description = "Public route table IDs of requester VPC route tables"
  type        = list(string)
  default     = []
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
  type        = list(string)
  default     = []
}


variable "accepter_public_route_table_ids" {
  description = "Public route table IDs of accepter VPC route tables"
  type        = list(string)
  default     = []
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


variable "enable_cross_account_peering" {
  description = "Control logic to create cross account peering not cross region"
  type        = string
  default     = ""
}

variable "create_peering" {
  description = "Regional VPC Peering creation control logic"
  type        = bool
  default     = true
}





# Cross account variables

variable "create_cross_account_peering" {
  description = "Cross account VPC Peering creation control variable"
  type        = bool
  default     = false
}


# For SSM Data sources
variable "requester_private_route_table_ids_key" {
  description = "Cross account requester private route table ids SSM Key"
  type        = string
  default     = ""
}

variable "requester_public_route_table_ids_key" {
  description = "Cross account requester private route table ids SSM Key"
  type        = string
  default     = ""
}

variable "requester_vpc_cidr_block_key" {
  description = "Cross account requester vpc cidr block SSM Key"
  type        = string
  default     = ""
}

variable "requester_vpc_id_key" {
  description = "Cross account requester vpc id SSM Key"
  type        = string
  default     = ""
}
variable "fetch_from_ssm" {
  description = "Cross account variables fetching from SSM enablement"
  type        = bool
  default     = true
}