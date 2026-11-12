variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "load_balancer_names" {
  description = "Names of the Application Load Balancers to alarm on. A name that matches no ALB fails the plan."
  type        = set(string)
}

variable "target_5xx_excluded" {
  description = "Load balancers that get only the load-balancer 5XX alarm, e.g. one whose targets fail chronically."
  type        = set(string)
  default     = []
}

variable "target_5xx_threshold" {
  description = "Alarm when target 5XX responses exceed this percentage of requests."
  type        = number
  default     = 10
}

variable "elb_5xx_threshold" {
  description = "Alarm when load-balancer 5XX responses exceed this percentage of requests."
  type        = number
  default     = 5
}

variable "min_requests" {
  description = "Requests per period below which the rate is treated as 0, so a single error on idle traffic does not alarm."
  type        = number
  default     = 200
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
