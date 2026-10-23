# aws-cloudwatch-mq-alarms

Alarms for one Amazon MQ broker, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

The engine and deployment mode are read from the broker. ActiveMQ is alarmed per instance (`<name>-1`,
`<name>-2`) and the active one's value is used, so the alarm follows a failover. RabbitMQ uses the
broker-level series, which carries the same values as each node and does not change when a node is replaced.

| Alarm | Default |
|---|---|
| `heap-high` | ActiveMQ: JVM heap above 90% |
| `store-high` | ActiveMQ: persistent store above 80% |
| `memory-high` | RabbitMQ: memory above 80% of the high watermark |
| `disk-free-low` | RabbitMQ: free disk below 2x the disk alarm limit |
| `no-data` | the broker published no CPU metric for the whole evaluation window (down or unreachable) |

Every threshold, the period and the datapoints are variables. Defaults: 5-minute period, 3 of 3 datapoints.

## Usage

```hcl
module "mq_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-mq-alarms?ref=module/aws-cloudwatch-mq-alarms/v0.1.0"

  name_prefix = "team-prod"
  name        = "orders"
  broker_name = "prod-orders-mq"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-mq-<name>-<alarm>`.
