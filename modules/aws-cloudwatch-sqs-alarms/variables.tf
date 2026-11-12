variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "queues" {
  description = <<-EOT
    Queues to alarm on, keyed by queue name. A name that matches no queue fails the plan.
    Each value overrides the module-wide default of the same name for that queue only; an omitted
    field uses the default. Use `{}` for a queue that needs no override.
    `metric` is `visible` (messages waiting in the queue) or `sent` (messages written to it).
  EOT
  type = map(object({
    messages_threshold = optional(number)
    metric             = optional(string)
  }))

  validation {
    condition     = alltrue([for q in var.queues : q.metric == null ? true : contains(["visible", "sent"], q.metric)])
    error_message = "metric must be \"visible\" or \"sent\"."
  }
}

variable "messages_threshold" {
  description = "Alarm when the metric reaches this many messages in one period."
  type        = number
  default     = 1
}

variable "metric" {
  description = "Default metric: `visible` (ApproximateNumberOfMessagesVisible, the one AWS recommends for dead-letter queues) or `sent` (NumberOfMessagesSent, which counts only messages written by hand, not those moved by a redrive policy)."
  type        = string
  default     = "visible"

  validation {
    condition     = contains(["visible", "sent"], var.metric)
    error_message = "metric must be \"visible\" or \"sent\"."
  }
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods evaluated."
  type        = number
  default     = 1
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger the alarm."
  type        = number
  default     = 1
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
