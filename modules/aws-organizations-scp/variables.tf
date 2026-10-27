variable "name" {
  description = "Name of the service control policy."
  type        = string
}

variable "description" {
  description = "Description of the service control policy."
  type        = string
  default     = null
}

variable "content" {
  description = "Policy document as a JSON string, for example from file() or jsonencode()."
  type        = string

  validation {
    condition     = can(jsondecode(var.content))
    error_message = "content must be a valid JSON document."
  }
}

variable "attach_to_root" {
  description = "Attach the policy to the organization root, which applies it to every member account."
  type        = bool
  default     = false
}

variable "target_ids" {
  description = "IDs of the OUs or accounts to attach the policy to, in addition to the root when attach_to_root is true."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for the policy."
  type        = map(string)
  default     = {}
}
