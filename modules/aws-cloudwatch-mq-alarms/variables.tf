variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "name" {
  description = "Short broker name used in alarm names, e.g. `orders`."
  type        = string
}

variable "broker_name" {
  description = "Amazon MQ broker name. ActiveMQ and RabbitMQ get different alarm sets."
  type        = string
}

variable "heap_threshold_pct" {
  description = "ActiveMQ JVM heap % above which the alarm fires."
  type        = number
  default     = 90
}

variable "store_threshold_pct" {
  description = "ActiveMQ persistent store % above which the alarm fires."
  type        = number
  default     = 80
}

variable "memory_threshold_pct" {
  description = "RabbitMQ memory, as % of its high watermark, above which the alarm fires."
  type        = number
  default     = 80
}

variable "disk_free_limit_multiple" {
  description = "RabbitMQ free disk, as a multiple of its disk alarm limit, below which the alarm fires."
  type        = number
  default     = 2
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
