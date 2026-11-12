# aws-cloudwatch-lambda-alarms

Error-rate, throttle and duration alarms for Lambda functions, looked up by name. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Three alarms per function:

- **error rate**: `Errors / Invocations`, default above 5% for 3 of 3 periods. The rate counts as 0 below
  `min_invocations` per period, so one failure on idle traffic does not alarm.
- **throttles**: `Throttles` at or above `throttle_threshold` (default 1) in a single period.
- **duration**: p99 `Duration` above a percentage of the function's own configured timeout (default 80%).
  The timeout is read from the function on every plan, so it cannot drift from what is deployed.

A function that fails at a known steady rate needs its own threshold. Set the module-wide defaults, then
override per function; an omitted field uses the default:

```hcl
module "lambda_alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-lambda-alarms/v0.1.0"

  name_prefix          = "team-prod"
  error_rate_threshold = 10 # default for every function below

  functions = {
    checkout = {}                                # 10%
    invoice  = { error_rate_threshold = 20 }     # 20%
    export   = { min_invocations = 50, duration_percent_of_timeout = 60 }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

| Per-function override | Default variable |
|---|---|
| `error_rate_threshold` | `error_rate_threshold` |
| `min_invocations` | `min_invocations` |
| `throttle_threshold` | `throttle_threshold` |
| `duration_percent_of_timeout` | `duration_percent_of_timeout` |
| `priority` | `priority` |

`enable_throttle_alarm` and `enable_duration_alarm` (both default `true`) switch those alarm kinds off for every
function, leaving the error-rate alarm.

`priority` (`P1` to `P5`, default none) is written at the start of each alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the description is unchanged.

`period`, `evaluation_periods` and `datapoints_to_alarm` are module-wide. The `effective_settings` output
shows the value in force for each function after overrides.

Functions are resolved by name: a name that matches no function fails the plan. Alarm names:
`<name_prefix>-lambda-<function>-<error-rate|throttles|duration>`.

The error rate is per function, so an alias or version with its own traffic is not separated; alarm on
the function name that carries the load.
