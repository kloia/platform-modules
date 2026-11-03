# aws-cloudwatch-ec2-alarms

Status check alarm for a group of EC2 instances, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Running instances are found by `Name` tag on every plan, so a replaced instance is covered on the next apply.
The alarm takes the worst instance.

| Alarm | Default |
|---|---|
| `status-check-failed` | instance or system status check failed for 10 minutes (2 of 2 five-minute periods) |

## Usage

```hcl
module "ec2_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-ec2-alarms?ref=module/aws-cloudwatch-ec2-alarms/v0.1.0"

  name_prefix    = "team-prod"
  name           = "workers"
  instance_names = ["prod-worker-01", "prod-worker-02"]

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-ec2-<name>-<alarm>`.
