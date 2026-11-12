variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "replication_instances" {
  description = <<-EOT
    Replication instances to alarm on, keyed by instance identifier. An identifier that matches no instance fails
    the plan. Each value overrides the module-wide default of the same name for that instance only; an omitted field
    uses the default. Use `{}` for an instance that needs no override.
  EOT
  type = map(object({
    cpu_threshold              = optional(number)
    free_storage_threshold_pct = optional(number)
  }))
  default = {}
}

variable "replication_tasks" {
  description = <<-EOT
    Replication tasks to alarm on, keyed by task ARN. `replication_instance` is the identifier of the instance the
    task runs on. CloudWatch keys task metrics by the last segment of the ARN, which the module derives. Each task may
    override the module-wide latency thresholds; an omitted field uses the default.
  EOT
  type = map(object({
    replication_instance       = string
    cdc_latency_source_seconds = optional(number)
    cdc_latency_target_seconds = optional(number)
  }))
  default = {}
}

variable "cpu_threshold" {
  description = "Alarm when replication instance CPU, in percent, reaches this value."
  type        = number
  default     = 80
}

variable "free_storage_threshold_pct" {
  description = "Alarm when free storage drops below this percentage of the instance's allocated storage."
  type        = number
  default     = 10
}

variable "cdc_latency_source_seconds" {
  description = "Alarm when CDC latency between the source and the replication instance reaches this many seconds."
  type        = number
  default     = 300
}

variable "cdc_latency_target_seconds" {
  description = "Alarm when CDC latency between the replication instance and the target reaches this many seconds."
  type        = number
  default     = 300
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods evaluated."
  type        = number
  default     = 5
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger the alarm."
  type        = number
  default     = 3
}

variable "description_suffix" {
  description = "Appended to every alarm description, e.g. where to look next."
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "ARNs notified when an alarm fires."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs notified when an alarm returns to OK."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for every alarm."
  type        = map(string)
  default     = {}
}

variable "priority" {
  description = <<-EOT
    Opsgenie priority, P1 to P5, written at the start of every alarm description as `[P2]`. An Opsgenie
    CloudWatch integration can read it from the description; leave it null when the integration has no such
    rule, and the description stays unchanged.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], var.priority)
    error_message = "priority must be one of P1, P2, P3, P4, P5."
  }
}
