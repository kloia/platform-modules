# aws-cloudwatch-alb-alarms

5XX-rate alarms for Application Load Balancers, looked up by name. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Two alarms per load balancer:

- **target 5XX rate**: `HTTPCode_Target_5XX_Count / RequestCount`, default above 10%
- **load balancer 5XX rate**: `HTTPCode_ELB_5XX_Count / RequestCount`, default above 5%

The rate counts as 0 below `min_requests` per period, so one error on idle traffic does not alarm.
Load balancers are resolved by name on every plan: one recreated by a controller gets a new ID and
is picked up, and a name that matches nothing fails the plan.

The rate is one number for everything behind the load balancer, so a small service failing
completely can stay under the threshold. Use `description_suffix` to say where the per-service view is.

## Usage

```hcl
module "alb_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-alb-alarms?ref=module/aws-cloudwatch-alb-alarms/v0.1.0"

  name_prefix         = "team-prod"
  load_balancer_names = ["prod-external", "prod-internal"]
  description_suffix  = "Per-service breakdown: your APM."

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-alb-<load balancer>-<target|elb>-5xx-rate`.

## Healthy-host alarm

The 5XX rates read 0 below `min_requests`, so a backend that is fully down at low traffic (overnight, for
example) does not alarm at all. List its target groups in `healthy_host_target_groups` to add one alarm
per target group on `HealthyHostCount`:

```hcl
  healthy_host_target_groups = ["prod-external-http-80"]
  min_healthy_hosts          = 1 # default
```

It fires when the minimum healthy count stays below `min_healthy_hosts` for 3 of 3 one-minute periods
(`healthy_host_period`, `healthy_host_evaluation_periods`, `healthy_host_datapoints_to_alarm`), at any traffic
level. Missing data counts as breaching: no datapoint means no target reported healthy. Each target group must
be attached to exactly one load balancer, which the plan checks.

Alarm names: `<name_prefix>-tg-<target group>-healthy-hosts`.

## Opsgenie priority

`priority` (`P1` to `P5`, default none) is written at the start of every alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the descriptions are unchanged.
