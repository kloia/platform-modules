variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "gateways" {
  description = <<-EOT
    NAT gateways to alarm on, keyed by a short label used in alarm names (e.g. `az-a`). `id` is the NAT gateway ID;
    an ID that matches no gateway fails the plan. Each gateway may override the module-wide thresholds; an omitted
    field uses the default. Zonal gateways only: regional gateways add an `AvailabilityZone` dimension.
  EOT
  type = map(object({
    id                              = string
    error_port_allocation_threshold = optional(number)
    packets_drop_threshold          = optional(number)
  }))
}

variable "error_port_allocation_threshold" {
  description = "Alarm when failed source-port allocations in one period reach this count."
  type        = number
  default     = 1
}

variable "packets_drop_threshold" {
  description = "Alarm when packets dropped by the gateway in one period reach this count."
  type        = number
  default     = 1
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
