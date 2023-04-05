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

variable "accepter_eks_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "accepter_all_private_route_table_ids"{
  description = "All private route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "accepter_mq_route_table_ids" {
  description = "The mq route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "accepter_database_route_table_ids" {
  description = "The database route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}
variable "requester_vpc_cidr_block" {
  description = "The CIDR Block of the requester VPC"
  type        = string
  default     = ""
}

variable "accepter_ecs_route_table_ids" {
  description = "The eks route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
}

variable "accepter_cache_route_table_ids" {
  description = "The cache route table IDs of accepter VPC route tables"
  type = list(string)
  default = []
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