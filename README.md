# aws-cloudwatch-sqs-alarms

Message-count alarms for SQS queues, typically dead-letter queues, looked up by name. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

One alarm per queue, firing when the metric reaches `messages_threshold` (default 1) in one period:

- `visible`: `ApproximateNumberOfMessagesVisible`, the metric AWS recommends for dead-letter queues. Use it
  for a queue that should normally be empty.
- `sent`: `NumberOfMessagesSent`. AWS documents that it counts messages written to a queue by hand and
  **not** messages moved there by a redrive policy, so use it only for a queue the application writes to
  directly and that is drained continuously.

Set the module-wide defaults, then override per queue; an omitted field uses the default:

```hcl
module "dlq_alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-sqs-alarms/v0.1.0"

  name_prefix = "team-prod"

  queues = {
    orders_error  = {}                                           # any visible message
    export_error  = { messages_threshold = 100 }                 # tolerates a small backlog
    ingest_error  = { metric = "sent", messages_threshold = 500 } # drained continuously
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Queues are resolved by name on every plan: a name that matches nothing fails the plan. Alarm names:
`<name_prefix>-sqs-<queue>-messages`. Missing data counts as not breaching, since SQS publishes these metrics
only while the queue is active. Sources: the SQS developer guide, "Available CloudWatch metrics for Amazon SQS".

## Opsgenie priority

`priority` (`P1` to `P5`, default none) is written at the start of every alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the descriptions are unchanged.
