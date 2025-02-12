resource "aws_budgets_budget" "budget" {
  for_each = { for budget in var.budgets : budget.name => budget }

  name = each.value.name

  budget_type  = each.value.budget_type
  limit_amount = each.value.limit_amount
  limit_unit   = each.value.limit_unit
  time_unit         = each.value.time_unit

  time_period_start = lookup(each.value, "time_period_start", null)
  time_period_end   = lookup(each.value, "time_period_end", null)

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
      name   = cost_filter.key
      values = cost_filter.value
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
