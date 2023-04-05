variable "environment" {
  description = "Environment tag (e.g. prod)."
  type        = string
}

variable "dns_name" {
  description = "Fully-qualified domain name (FQDN) to create."
  type        = string
}

variable "alarm_name_suffix" {
  description = "Suffix for cloudwatch alarm name to ensure uniqueness."
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "Actions to execute when this alarm transitions."
  type        = list(string)
  default     = cloudwatch.alarm_actions 
}

variable "health_check_regions" {
  description = "AWS Regions for health check"
  type        = list(string)
  default     = ["us-east-1","eu-west-1", "eu-west-2"]
}

variable "health_check_path" {
  description = "Resource Path to check"
  type        = string
  default     = ""
}

variable "failure_threshold" {
  description = "Failure Threshold (must be less than or equal to 10)"
  type        = string
  default     = "3"
}

variable "request_interval" {
  description = "Request Interval (must be 10 or 30)"
  type        = string
  default     = "30"
}

variable "disable" {
  description = "Disable health checks"
  type        = bool
  default     = false
}

