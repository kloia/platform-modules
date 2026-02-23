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

    filter_expression = optional(object({
      # Top-level leaf filters (used when no logical operator is needed)
      dimensions = optional(object({
        key           = string
        values        = list(string)
        match_options = optional(list(string))
      }))
      tags = optional(object({
        key           = string
        values        = list(string)
        match_options = optional(list(string))
      }))
      cost_categories = optional(object({
        key           = string
        values        = list(string)
        match_options = optional(list(string))
      }))

      # NOT logical operator
      not = optional(object({
        dimensions = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
        tags = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
        cost_categories = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
      }))

      # AND logical operator (list of expressions)
      and = optional(list(object({
        dimensions = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
        tags = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
        cost_categories = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
      })))

      # OR logical operator (list of expressions)
      or = optional(list(object({
        dimensions = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
        tags = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
        cost_categories = optional(object({
          key           = string
          values        = list(string)
          match_options = optional(list(string))
        }))
      })))
    }), null)

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
      }), null)

    tags = optional(map(string), {})
  }))
  default = []
  validation {
    condition = alltrue([
      for b in var.budgets :
      !(b.cost_filter != null && b.filter_expression != null)
    ])
    error_message = "A budget cannot have both 'cost_filter' and 'filter_expression' set at the same time. They are mutually exclusive."
  }
}
