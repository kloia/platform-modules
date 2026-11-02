variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "tables" {
  description = <<-EOT
    DynamoDB tables to alarm on, keyed by table name. A name that matches no table fails the plan.
    Each value overrides the module-wide default of the same name for that table only; an omitted
    field uses the default. Use `{}` for a table that needs no override.
  EOT
  type = map(object({
    read_throttle_threshold  = optional(number)
    write_throttle_threshold = optional(number)
  }))
}

variable "read_throttle_threshold" {
  description = "Alarm when read throttle events in one period reach this count."
  type        = number
  default     = 1
}

variable "write_throttle_threshold" {
  description = "Alarm when write throttle events in one period reach this count."
  type        = number
  default     = 1
}

variable "enable_read_throttle_alarm" {
  description = "Create the read throttle alarm for every table."
  type        = bool
  default     = true
}

variable "enable_write_throttle_alarm" {
  description = "Create the write throttle alarm for every table."
  type        = bool
  default     = true
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
