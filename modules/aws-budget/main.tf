resource "aws_budgets_budget" "budget" {
  for_each = { for budget in var.budgets : budget.name => budget }

  name = each.value.name

  budget_type  = each.value.budget_type
  limit_amount = each.value.limit_amount
  limit_unit   = each.value.limit_unit
  time_unit    = each.value.time_unit

  time_period_start = lookup(each.value, "time_period_start", null)
  time_period_end   = lookup(each.value, "time_period_end", null)

  dynamic "cost_types" {
    for_each = lookup(each.value, "cost_types", null) != null ? try(tolist(each.value.cost_types), [
      each.value.cost_types
    ]) : []
    content {
      include_credit             = lookup(cost_types.value, "include_credit", null)
      include_discount           = lookup(cost_types.value, "include_discount", null)
      include_other_subscription = lookup(cost_types.value, "include_other_subscription", null)
      include_recurring          = lookup(cost_types.value, "include_recurring", null)
      include_refund             = lookup(cost_types.value, "include_refund", null)
      include_subscription       = lookup(cost_types.value, "include_subscription", null)
      include_support            = lookup(cost_types.value, "include_support", null)
      include_tax                = lookup(cost_types.value, "include_tax", null)
      include_upfront            = lookup(cost_types.value, "include_upfront", null)
      use_amortized              = lookup(cost_types.value, "use_amortized", null)
      use_blended                = lookup(cost_types.value, "use_blended", null)
    }
  }

  dynamic "auto_adjust_data" {
    for_each = lookup(each.value, "auto_adjust_data", null) != null ? try(tolist(each.value.auto_adjust_data), [
      each.value.auto_adjust_data
    ]) : []

    content {
      auto_adjust_type = auto_adjust_data.value.auto_adjust_type

      dynamic "historical_options" {
        for_each = lookup(auto_adjust_data.value, "historical_options", null) != null ? try(tolist(auto_adjust_data.value.historical_options), [
          auto_adjust_data.value.historical_options
        ]) : []
        content {
          budget_adjustment_period = historical_options.value.budget_adjustment_period
        }
      }
    }
  }

  dynamic "cost_filter" {
    for_each = each.value.cost_filter == null ? {} : each.value.cost_filter
    content {
      name   = cost_filter.value.name
      values = cost_filter.value.values
    }
  }

  dynamic "notification" {
    for_each = lookup(each.value, "notification", null) != null ? try(tolist(each.value.notification), [
      each.value.notification
    ]) : []

    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_sns_topic_arns  = lookup(notification.value, "subscriber_sns_topic_arns", null)
      subscriber_email_addresses = lookup(notification.value, "subscriber_email_addresses", null)
    }
  }
}
