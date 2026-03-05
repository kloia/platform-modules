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

  dynamic "filter_expression" {
    for_each = lookup(each.value, "filter_expression", null) != null ? [each.value.filter_expression] : []

    content {

      # ── top-level leaf: dimensions ──────────────────────────────────────────
      dynamic "dimensions" {
        for_each = lookup(filter_expression.value, "dimensions", null) != null ? [filter_expression.value.dimensions] : []
        content {
          key           = dimensions.value.key
          values        = dimensions.value.values
          match_options = lookup(dimensions.value, "match_options", null)
        }
      }

      # ── top-level leaf: tags ────────────────────────────────────────────────
      dynamic "tags" {
        for_each = lookup(filter_expression.value, "tags", null) != null ? [filter_expression.value.tags] : []
        content {
          key           = tags.value.key
          values        = tags.value.values
          match_options = lookup(tags.value, "match_options", null)
        }
      }

      # ── top-level leaf: cost_categories ────────────────────────────────────
      dynamic "cost_categories" {
        for_each = lookup(filter_expression.value, "cost_categories", null) != null ? [filter_expression.value.cost_categories] : []
        content {
          key           = cost_categories.value.key
          values        = cost_categories.value.values
          match_options = lookup(cost_categories.value, "match_options", null)
        }
      }

      # ── NOT ─────────────────────────────────────────────────────────────────
      dynamic "not" {
        for_each = lookup(filter_expression.value, "not", null) != null ? [filter_expression.value.not] : []
        content {
          dynamic "dimensions" {
            for_each = lookup(not.value, "dimensions", null) != null ? [not.value.dimensions] : []
            content {
              key           = dimensions.value.key
              values        = dimensions.value.values
              match_options = lookup(dimensions.value, "match_options", null)
            }
          }
          dynamic "tags" {
            for_each = lookup(not.value, "tags", null) != null ? [not.value.tags] : []
            content {
              key           = tags.value.key
              values        = tags.value.values
              match_options = lookup(tags.value, "match_options", null)
            }
          }
          dynamic "cost_categories" {
            for_each = lookup(not.value, "cost_categories", null) != null ? [not.value.cost_categories] : []
            content {
              key           = cost_categories.value.key
              values        = cost_categories.value.values
              match_options = lookup(cost_categories.value, "match_options", null)
            }
          }
        }
      }

      # ── AND ─────────────────────────────────────────────────────────────────
      dynamic "and" {
        for_each = lookup(filter_expression.value, "and", null) != null ? filter_expression.value.and : []
        content {
          dynamic "dimensions" {
            for_each = lookup(and.value, "dimensions", null) != null ? [and.value.dimensions] : []
            content {
              key           = dimensions.value.key
              values        = dimensions.value.values
              match_options = lookup(dimensions.value, "match_options", null)
            }
          }
          dynamic "tags" {
            for_each = lookup(and.value, "tags", null) != null ? [and.value.tags] : []
            content {
              key           = tags.value.key
              values        = tags.value.values
              match_options = lookup(tags.value, "match_options", null)
            }
          }
          dynamic "cost_categories" {
            for_each = lookup(and.value, "cost_categories", null) != null ? [and.value.cost_categories] : []
            content {
              key           = cost_categories.value.key
              values        = cost_categories.value.values
              match_options = lookup(cost_categories.value, "match_options", null)
            }
          }
        }
      }

      # ── OR ──────────────────────────────────────────────────────────────────
      dynamic "or" {
        for_each = lookup(filter_expression.value, "or", null) != null ? filter_expression.value.or : []
        content {
          dynamic "dimensions" {
            for_each = lookup(or.value, "dimensions", null) != null ? [or.value.dimensions] : []
            content {
              key           = dimensions.value.key
              values        = dimensions.value.values
              match_options = lookup(dimensions.value, "match_options", null)
            }
          }
          dynamic "tags" {
            for_each = lookup(or.value, "tags", null) != null ? [or.value.tags] : []
            content {
              key           = tags.value.key
              values        = tags.value.values
              match_options = lookup(tags.value, "match_options", null)
            }
          }
          dynamic "cost_categories" {
            for_each = lookup(or.value, "cost_categories", null) != null ? [or.value.cost_categories] : []
            content {
              key           = cost_categories.value.key
              values        = cost_categories.value.values
              match_options = lookup(cost_categories.value, "match_options", null)
            }
          }
        }
      }
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

resource "aws_ce_anomaly_monitor" "service_monitor" {
  count = var.create_ce_anomaly_monitor ? 1 : 0

  name              = var.cost_anomaly_monitor_name
  monitor_type      = var.cost_anomaly_monitor_type
  monitor_dimension = var.cost_anomaly_monitor_type == "DIMENSIONAL" ? var.cost_anomaly_monitor_dimension : null
}

resource "aws_ce_anomaly_subscription" "subscription" {
  for_each = { for s in var.cost_anomaly_subscriptions : s.name => s }

  name             = each.value.name
  frequency        = each.value.frequency
  monitor_arn_list = concat(
    aws_ce_anomaly_monitor.service_monitor[*].arn,
    var.cost_anomaly_monitor_arn_list
  )

  threshold_expression {
    dynamic "dimension" {
      for_each = each.value.threshold_expression.dimension != null ? [each.value.threshold_expression.dimension] : []
      content {
        key           = dimension.value.key
        match_options = dimension.value.match_options
        values        = dimension.value.values
      }
    }

    dynamic "and" {
      for_each = each.value.threshold_expression.and != null ? each.value.threshold_expression.and : []
      content {
        dynamic "dimension" {
          for_each = and.value.dimension != null ? [and.value.dimension] : []
          content {
            key           = dimension.value.key
            match_options = dimension.value.match_options
            values        = dimension.value.values
          }
        }
      }
    }

    dynamic "or" {
      for_each = each.value.threshold_expression.or != null ? each.value.threshold_expression.or : []
      content {
        dynamic "dimension" {
          for_each = or.value.dimension != null ? [or.value.dimension] : []
          content {
            key           = dimension.value.key
            match_options = dimension.value.match_options
            values        = dimension.value.values
          }
        }
      }
    }
  }

  dynamic "subscriber" {
    for_each = each.value.subscribers
    content {
      type    = subscriber.value.type
      address = subscriber.value.address
    }
  }
}