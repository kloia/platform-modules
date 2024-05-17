variable "project_name" {
  description = "The name of the project you want to create"
  type        = string
}

variable "create_mongodbatlas_project" {
  type        = bool
  description = "Create mongoDB atlas project flag"
  default     = false

}

variable "org_id" {
  description = "The ID of the Atlas organization you want to create the project within"
  type        = string
}

variable "teams" {
  description = "An object that contains all the groups that should be created in the project"
  type        = map(any)
  default     = {}
}