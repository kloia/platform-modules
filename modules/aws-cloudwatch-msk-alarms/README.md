# aws-cloudwatch-msk-alarms

Alarms for one MSK provisioned cluster, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Broker IDs are read from AWS on every plan, so a broker added later is covered on the next apply.
`under-replicated-high` and `disk-used-high` take the worst broker in one metric math alarm, which holds at most
10 metrics: above 10 brokers they are skipped and the plan shows a warning. The other alarms are created for any
broker count.

`active-controller-low` treats missing data as breaching. This was tested on ZooKeeper-mode clusters; on a
KRaft-mode cluster, confirm `ActiveControllerCount` is published first, or set
`active_controller_treat_missing_data = "missing"`.

| Alarm | Default |
|---|---|
| `offline-partitions-high` | any partition without a leader, first datapoint |
| `active-controller-low` | no active controller |
| `under-replicated-high` | any under-replicated partition, worst broker |
| `disk-used-high` | data log disk above 80%, worst broker |
| `cpu-high-broker-<id>` | CPU user + system above 60%, one alarm per broker ([AWS best practice](https://docs.aws.amazon.com/msk/latest/developerguide/bestpractices.html#bestpractices-monitor-cpu)) |

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

## Opsgenie priority

`priority` (`P1` to `P5`, default none) is written at the start of every alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the descriptions are unchanged.
