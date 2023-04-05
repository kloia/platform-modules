variable "name" {
  type        = string
  description = "(Required) Name of Cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "(Required) List of Subnets to use for Cluster Group"
}

variable "query_ttl" {
  type        = string
  description = "(optional) Query Time To Live in milliseconds Defaults: 300000"
  default     = "300000"
}

variable "record_ttl" {
  type        = string
  description = "(optional) Record Time To Live in milliseconds Defaults: 300000"
  default     = "300000"
}


variable "node_type" {
  type        = string
  description = "(Required) The compute and memory capacity of the nodes"
}

variable "node_count" {
  type        = number
  description = "(Required) The number of nodes in the DAX cluster. If 1 then it will create a single-node cluster, without any read replicas [ Default to 1 ]"
  default     = 1
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Specifies the weekly time range for when maintenance on the cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Defaults: sun:00:00-sun:01:00"
  default     = "sun:00:00-sun:01:00"
}

variable "server_side_encryption" {
  type        = bool
  description = "(Optional) Encrypt at rest options Default = true"
  default     = true
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  default = ""
}

variable "vpc_id" {
  description = "vpc id"
  default = ""
}

variable "iam_role_name" {

  description = "role name of dax cluster"
  default = ""
  
}