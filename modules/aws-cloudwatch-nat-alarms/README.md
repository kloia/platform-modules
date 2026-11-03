# aws-cloudwatch-nat-alarms

Alarms for the NAT gateways of one VPC, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

The available NAT gateways are read from AWS on every plan, so a gateway added later is covered on the
next apply. The alarm takes the worst gateway.

| Alarm | Default |
|---|---|
| `port-allocation-errors` | any `ErrorPortAllocation` in a 5-minute period, first datapoint |

A value above zero means the gateway could not open a new connection because too many are already open to
the same destination ([NAT gateway metrics](https://docs.aws.amazon.com/vpc/latest/userguide/metrics-dimensions-nat-gateway.html)).
Those connections fail at once, so the alarm fires on the first datapoint.

## Usage

```hcl
module "nat_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-nat-alarms?ref=module/aws-cloudwatch-nat-alarms/v0.1.0"

  name_prefix = "team-prod"
  name        = "main"
  vpc_id      = "vpc-0123456789abcdef0"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-nat-<name>-<alarm>`.
