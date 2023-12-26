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
  default     = []
}

variable "health_check_regions" {
  description = "AWS Regions for health check"
  type        = list(string)
  default     = ["us-east-1","eu-west-1", "ap-southeast-1"]
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

variable "port" {
  description = "Port for TCP (between 0 to 65535)"
  type        = number
  default     = 443
}

variable "enable_cloudwatch_alarm" {
  description = "Enable cloudwatch alarm"
  type        = bool
  default     = true
}

variable "health_check_type" {
  description = <<-EOT
  The health check type to use.
  The value specified can either be `HTTP`, `HTTPS`,
  and/or `TCP`.

  Defaults to `HTTP` and `HTTPS`.
  EOT
  type        = set(string)
  default     = ["HTTP", "HTTPS"]
  validation {
    condition     = length(setintersection(["HTTP", "HTTPS", "TCP"], var.health_check_type)) > 0
    error_message = "Health check type must be one be one of: HTTP, HTTPS, TCP."
  }
}
