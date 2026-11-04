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
