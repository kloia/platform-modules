variable "role_arn" {
  description = "(Optional) The ARN of an IAM role that grants Amazon CloudWatch Logs permissions to deliver ingested log events to the destination. If you use Lambda as a destination, you should skip this argument and use aws_lambda_permission resource for granting access from CloudWatch logs to the destination Lambda function."
  type        = string
  default     = ""
}

variable "filter_pattern" {
  description = "(Required) A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events."
  type        = string
  default     = ""
}

variable "destination_arn" {
  description = "(Required) The ARN of the destination to deliver matching log events to. Kinesis stream or Lambda function ARN."
  type        = string
  default     = ""
}

variable "log_group_names" {
  description = "(Required) The names of the log group to associate the subscription filter with"
  type        = list
  default     = []
}