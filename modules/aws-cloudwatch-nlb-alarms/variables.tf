variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "load_balancers" {
  description = <<-EOT
    Network Load Balancers to alarm on, keyed by load balancer name. `target_group_names` lists the target groups
    whose health is alarmed; a name that matches no load balancer or target group fails the plan. A target group
    added later must be added here. At most 10 target groups share one alarm (the CloudWatch limit on metrics per
    alarm); more are split into further alarms automatically.
  EOT
  type = map(object({
    target_group_names = list(string)
  }))
}

variable "unhealthy_hosts_threshold" {
  description = "Alarm when the minimum UnHealthyHostCount of the worst target group exceeds this value."
  type        = number
  default     = 0
}

variable "min_healthy_hosts" {
  description = "Alarm when the maximum HealthyHostCount of the worst target group falls below this value."
  type        = number
  default     = 1
}

variable "port_allocation_errors_threshold" {
  description = "Alarm when ephemeral port allocation errors in one period reach this count. Evaluated on one period, since a non-zero value already means dropped client connections."
  type        = number
  default     = 1
}

variable "treat_missing_healthy_data" {
  description = "How the no-healthy-hosts alarm treats missing data. Health metrics are reported only while targets are registered, so `breaching` also catches a target group emptied of targets."
  type        = string
  default     = "breaching"
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods evaluated by the health alarms."
  type        = number
  default     = 3
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger a health alarm."
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
