variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "name" {
  description = "Short name used in alarm names, e.g. `wildcard`."
  type        = string
}

variable "domain" {
  description = "Domain name of the certificate, e.g. `*.example.com`."
  type        = string
}

variable "certificate_types" {
  description = "Certificate types to match. ACM renews AMAZON_ISSUED certificates itself; IMPORTED ones need this alarm most."
  type        = list(string)
  default     = ["IMPORTED"]
}

variable "days_threshold" {
  description = "Days before expiry at which the alarm fires."
  type        = number
  default     = 30
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
