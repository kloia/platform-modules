<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.budget](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budgets"></a> [budgets](#input\_budgets) | A collection of budgets to provision | <pre>list(object({<br/>    name         = string<br/>    budget_type  = optional(string, "COST")<br/>    limit_amount = optional(string, "100.0")<br/>    limit_unit   = optional(string, "PERCENTAGE")<br/>    time_unit    = optional(string, "MONTHLY")<br/><br/>    time_period_start = optional(string)<br/>    time_period_end   = optional(string)<br/><br/>    auto_adjust_data = optional(object({<br/>      auto_adjust_type = optional(string)<br/>      historical_options = optional(object({<br/>        budget_adjustment_period = string<br/>      }))<br/>    }), {})<br/><br/>    notification = optional(object({<br/>      comparison_operator = string<br/>      threshold           = number<br/>      threshold_type      = string<br/>      notification_type   = string<br/><br/>      subscriber_email_addresses = optional(list(string))<br/>      subscriber_sns_topic_arns = optional(list(string))<br/>    }), null)<br/><br/>    cost_filter = optional(map(object({<br/>      name   = string<br/>      values = list(string)<br/>    })), {})<br/><br/>    cost_types = optional(object({<br/>      include_credit             = optional(bool, false)<br/>      include_discount           = optional(bool, false)<br/>      include_other_subscription = optional(bool, false)<br/>      include_recurring          = optional(bool, false)<br/>      include_refund             = optional(bool, false)<br/>      include_subscription       = optional(bool, false)<br/>      include_support            = optional(bool, false)<br/>      include_tax                = optional(bool, false)<br/>      include_upfront            = optional(bool, false)<br/>      use_blended                = optional(bool, false)<br/>      }), {<br/>      include_credit             = false<br/>      include_discount           = false<br/>      include_other_subscription = false<br/>      include_recurring          = false<br/>      include_refund             = false<br/>      include_subscription       = true<br/>      include_support            = false<br/>      include_tax                = false<br/>      include_upfront            = false<br/>      use_blended                = false<br/>    })<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->