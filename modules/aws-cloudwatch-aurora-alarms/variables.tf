variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "name" {
  description = "Short cluster name used in alarm names, e.g. `primary`."
  type        = string
}

variable "cluster_identifier" {
  description = "Aurora cluster identifier. Its current members are alarmed on."
  type        = string
}

variable "enable_dbload_alarm" {
  description = "DB load per vCPU alarm. Needs Performance Insights on every instance."
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "CPU % above which the worst instance alarms."
  type        = number
  default     = 80
}

variable "freeable_memory_threshold_pct" {
  description = "Freeable memory, as % of the instance's memory, below which the lowest instance alarms."
  type        = number
  default     = 5
}

variable "local_storage_threshold_pct" {
  description = "Free local storage, as % of the instance's local storage, below which the lowest instance alarms."
  type        = number
  default     = 10
}

variable "deadlocks_threshold" {
  description = "Deadlocks per second above which the worst instance alarms."
  type        = number
  default     = 0.1
}

variable "dbload_threshold" {
  description = "Average active sessions per vCPU above which the worst instance alarms."
  type        = number
  default     = 3
}

variable "replica_lag_threshold_ms" {
  description = "Reader lag in milliseconds above which the alarm fires. Only created when the cluster has a reader."
  type        = number
  default     = 5000
}

variable "enable_global_replication_lag_alarm" {
  description = "Alarm on Aurora Global replication lag. Set on the secondary cluster, in the secondary region."
  type        = bool
  default     = false
}

variable "global_replication_lag_threshold_ms" {
  description = "Aurora Global replication lag in milliseconds above which the alarm fires."
  type        = number
  default     = 30000
}

variable "local_storage_gib" {
  description = "Local storage per instance class in GiB, merged over the built-in Aurora PostgreSQL table."
  type        = map(number)
  default     = {}
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
