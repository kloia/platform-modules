variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "name" {
  description = "Short replication group name used in alarm names, e.g. `sessions`."
  type        = string
}

variable "replication_group_id" {
  description = "ElastiCache replication group ID. Its current member nodes are alarmed on."
  type        = string
}

variable "engine_cpu_threshold" {
  description = "Redis engine CPU % above which the worst node alarms."
  type        = number
  default     = 80
}

variable "memory_threshold_pct" {
  description = "Memory used, as % of maxmemory, above which the worst node alarms."
  type        = number
  default     = 85
}

variable "evictions_threshold" {
  description = "Evicted keys per period above which the worst node alarms."
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
