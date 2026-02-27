variable "budgets" {
  description = "A collection of budgets to provision"
  type = list(object({
    name         = string
    budget_type  = optional(string, "COST")
    limit_amount = optional(string, "100.0")
    limit_unit   = optional(string, "PERCENTAGE")
    time_unit    = optional(string, "MONTHLY")

    time_period_start = optional(string)
    time_period_end   = optional(string)

    auto_adjust_data = optional(object({
      auto_adjust_type = optional(string)
      historical_options = optional(object({
        budget_adjustment_period = string
      }))
    }), null)

    notification = optional(object({
      comparison_operator = string
      threshold           = number
      threshold_type      = string
      notification_type   = string

      subscriber_email_addresses = optional(list(string))
      subscriber_sns_topic_arns  = optional(list(string))
    }), null)

    cost_filter = optional(map(object({
      name   = string
      values = list(string)
    })), null)

    cost_types = optional(object({
      include_credit             = optional(bool, false)
      include_discount           = optional(bool, false)
      include_other_subscription = optional(bool, false)
      include_recurring          = optional(bool, false)
      include_refund             = optional(bool, false)
      include_subscription       = optional(bool, false)
      include_support            = optional(bool, false)
      include_tax                = optional(bool, false)
      include_upfront            = optional(bool, false)
      use_blended                = optional(bool, false)
      }), {
      include_credit             = false
      include_discount           = false
      include_other_subscription = false
      include_recurring          = false
      include_refund             = false
      include_subscription       = true
      include_support            = false
      include_tax                = false
      include_upfront            = false
      use_blended                = false
    })

    tags = optional(map(string), {})
  }))
  default = []
}

variable "create_ce_anomaly_monitor" {
  description = "Whether to create a Cost Explorer anomaly monitor."
  type        = bool
  default     = false
}

variable "cost_anomaly_monitor_name" {
  description = "The name of the monitor."
  type        = string
  default     = "Kloia-Services-Monitor"
}

variable "cost_anomaly_monitor_type" {
  description = "The possible type values are DIMENSIONAL, CUSTOM. DIMENSIONAL monitors specific AWS service dimensions. CUSTOM monitors based on a custom expression."
  type        = string
  default     = "DIMENSIONAL"
}

variable "cost_anomaly_monitor_dimension" {
  description = "The dimension to monitor. Only applicable when monitor_type is DIMENSIONAL. Valid value: SERVICE."
  type        = string
  default     = "SERVICE"
}

variable "cost_anomaly_monitor_arn_list" {
  description = "A list of cost anomaly monitor ARNs to associate with all subscriptions. Combined with the ARN of the monitor created by this module if create_ce_anomaly_monitor is true."
  type        = list(string)
  default     = []
}

variable "cost_anomaly_subscriptions" {
  description = <<-EOT
    List of anomaly subscriptions to create. Each subscription has its own frequency, threshold, and subscribers.
    DAILY/WEEKLY frequency only supports EMAIL subscribers.
    IMMEDIATE frequency supports both EMAIL and SNS subscribers.

    Example:
      cost_anomaly_subscriptions = [
        {
          name      = "daily-email-digest"
          frequency = "DAILY"
          threshold_expression = {
            and = [
              { dimension = { key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE",    match_options = ["GREATER_THAN_OR_EQUAL"], values = ["100"] } },
              { dimension = { key = "ANOMALY_TOTAL_IMPACT_PERCENTAGE", match_options = ["GREATER_THAN_OR_EQUAL"], values = ["20"]  } }
            ]
          }
          subscribers = [
            { type = "EMAIL", address = "finops@kloia.com" }
          ]
        },
        {
          name      = "immediate-sns-alert"
          frequency = "IMMEDIATE"
          threshold_expression = {
            dimension = { key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE", match_options = ["GREATER_THAN_OR_EQUAL"], values = ["100"] }
          }
          subscribers = [
            { type = "SNS", address = "arn:aws:sns:us-east-1:123456789:alerts" }
          ]
        }
      ]
  EOT
  type = list(object({
    name      = string
    frequency = string
    threshold_expression = object({
      dimension = optional(object({
        key           = string
        match_options = list(string)
        values        = list(string)
      }))
      and = optional(list(object({
        dimension = optional(object({
          key           = string
          match_options = list(string)
          values        = list(string)
        }))
      })))
      or = optional(list(object({
        dimension = optional(object({
          key           = string
          match_options = list(string)
          values        = list(string)
        }))
      })))
    })
    subscribers = list(object({
      type    = string
      address = string
    }))
  }))
  default = []
}