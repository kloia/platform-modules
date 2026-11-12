# aws-cloudwatch-nlb-alarms

Target health and port allocation alarms for Network Load Balancers, looked up by name. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Per load balancer:

- **unhealthy-hosts**: the worst target group's `UnHealthyHostCount` (Minimum across load balancer nodes) above `unhealthy_hosts_threshold` (default 0), 3 of 3 periods of 5 minutes.
- **no-healthy-hosts**: the worst target group's `HealthyHostCount` (Maximum across nodes) below `min_healthy_hosts` (default 1), 3 of 3. Missing data counts as breaching by default, because health metrics are reported only while targets are registered, so a target group emptied of targets alarms too. Set `treat_missing_healthy_data = "missing"` to turn that off.
- **port-allocation-errors**: `PortAllocationErrorCount` (Sum) at or above 1 in one period. Any non-zero value means dropped client connections.

One alarm covers up to 10 target groups (the CloudWatch limit on metrics per alarm); more are split into further alarms named with a `-2`, `-3` suffix. Load balancers and target groups are resolved by name on every plan; a name that matches nothing fails the plan. A target group added later must be added to `target_group_names`.

TCP reset counts are not alarmed: clients reset connections routinely.

## Usage

```hcl
module "nlb_alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-nlb-alarms/v0.1.0"

  name_prefix = "team-prod"

  load_balancers = {
    my-nlb = { target_group_names = ["my-tg-a", "my-tg-b"] }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Names: `<name_prefix>-nlb-<load balancer>-<unhealthy-hosts|no-healthy-hosts>[-2]` and `<name_prefix>-nlb-<load balancer>-port-allocation-errors`.

Sources: Network Load Balancer user guide, "CloudWatch metrics for your Network Load Balancer", keywords *"It's recommended to monitor maximum `HealthyHostCount`"*, *"It's also recommended to monitor minimum `UnHealthyHostCount`"* and, for `PortAllocationErrorCount`, *"A non-zero value indicates dropped client connections."* The 10-metric limit: `aws cloudwatch put-metric-alarm help`, *"as many as 10 structures that contain a MetricStat parameter"*.

## Opsgenie priority

`priority` (`P1` to `P5`, default none) is written at the start of every alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the descriptions are unchanged.
