variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "distributions" {
  description = <<-EOT
    CloudFront distributions to alarm on, keyed by a short label used in alarm names. `id` is the distribution ID;
    an ID that matches no distribution fails the plan. Each distribution may override the module-wide defaults of
    the same name; an omitted field uses the default. Use `{ id = "..." }` for a distribution that needs no override.
  EOT
  type = map(object({
    id                   = string
    error_rate_threshold = optional(number)
    min_requests         = optional(number)
  }))
}

variable "error_rate_threshold" {
  description = "Alarm when the 5XX error rate, in percent of viewer requests, exceeds this value."
  type        = number
  default     = 5
}

variable "min_requests" {
  description = "Requests per period below which the rate is treated as 0, so a few errors on idle traffic do not alarm."
  type        = number
  default     = 100
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

variable "description_suffix" {
  description = "Appended to every alarm description, e.g. where to look next."
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "ARNs notified when an alarm fires. Must be in us-east-1, the region of the alarms."
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
