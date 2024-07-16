variable "name" {
  description = "The name of the CloudWatch dashboard"
  type        = string
  default     = "my-dashboard"
}

variable "applications" {
  description = "List of application names"
  type        = list(string)
}

variable "namespaces" {
  description = "List of namespace names"
  type        = list(string)
}

variable "environment" {
  type        = string
  description = "environment of eks or rds"
}

variable "region" {
  type        = string
  description = "AWS region"
}
