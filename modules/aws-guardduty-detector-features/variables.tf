variable "detector_id" {
  description = "ID of the GuardDuty detector to configure. When null, the detector of the current account and Region is looked up."
  type        = string
  default     = null
}

variable "features" {
  description = <<-EOT
    Protection plans to manage, keyed by feature name: S3_DATA_EVENTS,
    EKS_AUDIT_LOGS, EBS_MALWARE_PROTECTION, RDS_LOGIN_EVENTS,
    LAMBDA_NETWORK_LOGS or RUNTIME_MONITORING. `status` is ENABLED or DISABLED.
    `additional_configuration` maps a sub-feature name (for example
    ECS_FARGATE_AGENT_MANAGEMENT under RUNTIME_MONITORING) to its status.
  EOT
  type = map(object({
    status                   = string
    additional_configuration = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for f in values(var.features) : contains(["ENABLED", "DISABLED"], f.status)])
    error_message = "Each feature status must be ENABLED or DISABLED."
  }
}
