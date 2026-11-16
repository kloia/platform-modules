variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "name" {
  description = "Short cluster name used in alarm names, e.g. `events`."
  type        = string
}

variable "cluster_name" {
  description = "MSK provisioned cluster name. Its current brokers are alarmed on."
  type        = string
}

variable "cpu_threshold_pct" {
  description = "Broker CPU (CpuUser + CpuSystem) % above which the worst broker alarms."
  type        = number
  default     = 60
}

variable "disk_used_threshold_pct" {
  description = "Data log disk used % above which the worst broker alarms."
  type        = number
  default     = 80
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods evaluated."
  type        = number
  default     = 3
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger the alarm."
  type        = number
  default     = 3
}

variable "under_replicated_datapoints" {
  description = "Breaching periods that trigger under-replicated-high, and its evaluation window. Null uses datapoints_to_alarm. Raise it above one broker restart (MSK patching rolls each broker for about 15 minutes) to stop maintenance alarms."
  type        = number
  default     = null
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

variable "active_controller_treat_missing_data" {
  description = "Missing ActiveControllerCount data counts as no controller by default. Tested on ZooKeeper-mode clusters; check that a KRaft-mode cluster publishes the metric before relying on the default."
  type        = string
  default     = "breaching"
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
