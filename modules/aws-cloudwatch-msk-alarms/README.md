# aws-cloudwatch-msk-alarms

Alarms for one MSK provisioned cluster, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Broker IDs are read from AWS on every plan, so a broker added later is covered on the next apply.
Per-broker alarms take the worst broker.

| Alarm | Default |
|---|---|
| `offline-partitions-high` | any partition without a leader, first datapoint |
| `active-controller-low` | no active controller |
| `under-replicated-high` | any under-replicated partition, worst broker |
| `disk-used-high` | data log disk above 80%, worst broker |

Every threshold, the period and the datapoints are variables. Defaults: 5-minute period, 3 of 3 datapoints.

## Usage

```hcl
module "kafka_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-msk-alarms?ref=module/aws-cloudwatch-msk-alarms/v0.1.0"

  name_prefix = "team-prod"
  name         = "events"
  cluster_name = "prod-kafka-cluster"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-kafka-<name>-<alarm>`.
