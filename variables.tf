variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "gateways" {
  description = <<-EOT
    Transit gateways to alarm on, keyed by a short label used in alarm names. `id` is the transit gateway ID; an ID
    that matches no gateway fails the plan. Each gateway may override the module-wide thresholds; an omitted field
    uses the default.
  EOT
  type = map(object({
    id                  = string
    blackhole_threshold = optional(number)
    no_route_threshold  = optional(number)
  }))
}

variable "blackhole_threshold" {
  description = "Alarm when packets dropped by a blackhole route in one period reach this count."
  type        = number
  default     = 1
}

variable "no_route_threshold" {
  description = "Alarm when packets dropped for lack of a matching route in one period reach this count."
  type        = number
  default     = 1
}

variable "enable_no_route_alarm" {
  description = "Create the no-route alarm. Off by default: stray traffic can legitimately match no route."
  type        = bool
  default     = false
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
