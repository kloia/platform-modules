variable "database_users"{
    type = map(any)
    default = {}
}

variable "cluster_name"{
    description = "Mongoatlas cluster name"
}

variable "project_id"{
    description = "Mongoatlas project ID"
}