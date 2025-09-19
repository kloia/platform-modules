#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}


/* variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
} */

/* variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
} */

/* variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-cloudwatch-event-rule"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
} */

/* variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
} */

#Module      : CLOUDWATCH METRIC ALARM
#Description : Provides a CloudWatch Metric Alarm resource.
variable "enabled" {
  type        = bool
  default     = true
  description = "Enable event."
}

variable "description" {
  type        = string
  default     = ""
  description = "The description for the rule."
}

variable "schedule_expression" {
  default     = null
  description = "(if event_pattern isn't specified) The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)."
}

variable "event_pattern" {
  default     = null
  description = "(schedule_expression isn't specified) Event pattern described a JSON object. See full documentation of CloudWatch Events and Event Patterns for details."
}

variable "role_arn" {
  type        = string
  default     = ""
  description = "The Amazon Resource Name (ARN) associated with the role that is used for target invocation."
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Whether the rule should be enabled (defaults to true)."
}

variable "target_id" {
  type        = string
  default     = ""
  description = "The Amazon Resource Name (ARN) associated with the role that is used for target invocation."
}

variable "arn" {
  type        = string
  default     = ""
  description = "The Amazon Resource Name (ARN) associated with the role that is used for target invocation."
}

variable "input_path" {
  type        = string
  default     = ""
  description = "The value of the JSONPath that is used for extracting part of the matched event when passing it to the target."
}

variable "target_role_arn" {
  type        = string
  default     = ""
  description = "The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered. Required if ecs_target is used."
}

variable "input_paths" {
  type        = map(any)
  default     = {}
  description = "Key value pairs specified in the form of JSONPath (for example, time = $.time)"

}

variable "input_template" {
  type        = string
  default     = ""
  description = "Template to customize data sent to the target. Must be valid JSON. To send a string value, the string value must include double quotes. Values must be escaped for both JSON and Terraform,"
}