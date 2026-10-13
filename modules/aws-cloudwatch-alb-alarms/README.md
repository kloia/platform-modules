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
