# aws-cloudwatch-stepfunctions-alarms

Failed, timed-out and throttled execution alarms for Step Functions state machines, looked up by name.

Up to three alarms per state machine, each firing when the metric reaches its threshold (default 1) in one period:

- **failed**: `ExecutionsFailed`, Sum
- **timed out**: `ExecutionsTimedOut`, Sum
- **throttled**: `ExecutionThrottled`, Sum. AWS documents that it is emitted only when throttling happens, so
  this alarm stays `OK` with no data until then. Set `enable_throttled_alarm` to `false` to omit it.

The metrics are keyed by the state machine ARN, which the module reads from the state machine on every plan.
AWS notes that CloudWatch delivery of these metrics is best-effort, so a failed execution can appear late. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Set the module-wide defaults, then override per resource; an omitted field uses the default:

```hcl
module "alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-stepfunctions-alarms/v0.1.0"

  name_prefix = "team-prod"

  state_machines = {
    nightly-export = {}                             # any failure
    cleanup        = { failed_threshold = 5 }      # tolerates a few
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Missing data counts as not breaching. Names: `<name_prefix>-sfn-<state machine>-<failed|timed-out|throttled>`. Source: Step Functions developer guide, "Monitoring Step Functions metrics using Amazon CloudWatch".

## Opsgenie priority

`priority` (`P1` to `P5`, default none) is written at the start of every alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the descriptions are unchanged.
