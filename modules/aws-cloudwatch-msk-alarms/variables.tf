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
