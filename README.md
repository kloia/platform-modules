# aws-cloudwatch-aurora-alarms

Alarms for one Aurora cluster, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

The cluster's members and their instance classes are read from AWS on every plan, so a reader added
later is covered on the next apply and sizes always match the running class.

| Alarm | Default | Across instances |
|---|---|---|
| `cpu-high` | CPU above 80% | worst instance |
| `freeable-memory-low` | below 5% of the instance's memory | lowest instance, each as % of its own size |
| `local-storage-low` | below 10% of the instance's local storage | lowest instance, each as % of its own size |
| `deadlocks-high` | above 0.1/s | worst instance |
| `dbload-high` | active sessions above 3x vCPUs (`enable_dbload_alarm`, needs Performance Insights) | worst instance |
| `replica-lag-high` | reader lag above 5 s, only when the cluster has a reader | worst reader |

Taking the worst instance keeps an alarm valid after a writer failover. Percentages per instance
matter because instances of one cluster can be different classes.

Memory comes from the EC2 instance type. Local storage comes from the Aurora PostgreSQL table in
[Temporary storage limits for Aurora PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Managing.html);
a class missing from it fails the plan. For other engines or new classes, pass `local_storage_gib`.

## Usage

```hcl
module "aurora_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-aurora-alarms?ref=module/aws-cloudwatch-aurora-alarms/v0.1.0"

  name_prefix        = "team-prod"
  name               = "primary"
  cluster_identifier = "prod-aurora-primary"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-aurora-<name>-<alarm>`.
