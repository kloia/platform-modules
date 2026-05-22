################################################################################
# Athena Workgroup
################################################################################

variable "create_workgroup" {
  description = "Whether to create the Athena workgroup."
  type        = bool
  default     = true
}

variable "workgroup_name" {
  description = "Name of the Athena workgroup."
  type        = string
}

variable "workgroup_description" {
  description = "Description of the Athena workgroup."
  type        = string
  default     = null
}

variable "workgroup_state" {
  description = "State of the workgroup. ENABLED or DISABLED."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.workgroup_state)
    error_message = "workgroup_state must be ENABLED or DISABLED."
  }
}

variable "enforce_workgroup_configuration" {
  description = "Enforce workgroup result location and encryption settings for all queries."
  type        = bool
  default     = true
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Publish workgroup-level query metrics to CloudWatch."
  type        = bool
  default     = true
}

variable "bytes_scanned_cutoff_per_query" {
  description = "Maximum bytes scanned per query. Queries exceeding this are cancelled. null disables the limit."
  type        = number
  default     = null
}

variable "results_output_location" {
  description = "S3 URL for query results (e.g., s3://my-bucket/prefix/)."
  type        = string
}

variable "encryption_option" {
  description = "Encryption option for query results: SSE_S3, SSE_KMS, or CSE_KMS. null disables encryption configuration."
  type        = string
  default     = null

  validation {
    condition     = var.encryption_option == null || contains(["SSE_S3", "SSE_KMS", "CSE_KMS"], var.encryption_option)
    error_message = "encryption_option must be SSE_S3, SSE_KMS, CSE_KMS, or null."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE_KMS or CSE_KMS encryption. Required when encryption_option is SSE_KMS or CSE_KMS."
  type        = string
  default     = null
}

################################################################################
# Named Queries
################################################################################

variable "named_queries" {
  description = "Map of named (saved) Athena queries. Key is the query name. Each value: database (string), query (string), description (optional string)."
  type = map(object({
    database    = string
    query       = string
    description = optional(string)
  }))
  default = {}
}

################################################################################
# Common
################################################################################

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
