#variable "namespace" {
#  description = "The namespace we interpolate in all resources"
#}

variable "create" {
  description = "create defines if resources need to be created true/false"
  default     = true
}

# The name of the ECR repository
variable "ecr_repo_names" {
  description = "name defines the name of the repository, by default it will be interpolated to {namespace}-{name}"
  type        = list(any)
}


variable "allowed_read_principals" {
  description = "allowed_read_principals defines which external principals are allowed to read from the ECR repository"
  type        = list(any)
}

variable "allowed_write_principals" {
  description = "allowed_write_principals defines which external principals are allowed to write to the ECR repository"
  type        = list(any)
  default     = []
}

variable "lifecycle_policy" {
  description = "Default JSON lifecycle policy to apply to all ECR repositories. Leave empty to skip."
  type        = string
  default     = ""
}

variable "lifecycle_policy_overrides" {
  description = "Map of repo name to JSON lifecycle policy. Repos in this map use their dedicated policy instead of the default lifecycle_policy."
  type        = map(string)
  default     = {}
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE."
  default     = "MUTABLE"
}

variable "scan_on_pushing" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  default     = {}
}


variable "secondary_region" {
  description = "Region to Create ECR Registry"
  type        = string
}

variable "organization_id" {
  type        = string
  default     = ""
  description = "organization id"
}