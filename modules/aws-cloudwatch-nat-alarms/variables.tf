variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "name" {
  description = "Short name used in alarm names, e.g. `main`."
  type        = string
}

variable "vpc_id" {
  description = "VPC whose available NAT gateways are alarmed on. Null covers every NAT gateway in the region."
  type        = string
  default     = null
}

variable "port_allocation_errors_threshold" {
  description = "Port allocation errors per period above which the worst NAT gateway alarms."
  type        = number
  default     = 0
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
