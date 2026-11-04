# aws-cloudwatch-dms-alarms

CPU, free-storage and CDC-latency alarms for AWS DMS, in two inputs.

Per replication instance (`replication_instances`, looked up by identifier):

- **cpu**: `CPUUtilization`, Maximum, default 80%.
- **free storage**: `FreeStorageSpace`, Minimum, below a percentage (default 10%) of the instance's allocated
  storage, which the module reads from the instance. Task logs fill this disk and the instance stops at
  `storage-full`.

Per replication task (`replication_tasks`, keyed by task ARN):

- **CDC latency, source** and **target**: `CDCLatencySource` and `CDCLatencyTarget`, Maximum, default 300 seconds.
  AWS advises comparing the two: a high source value points at the source, a high target value at the target or
  the instance.

CloudWatch keys task metrics by the last segment of the task ARN, not by the task name, so tasks are given by ARN
and the module derives it. They also carry the instance identifier, given as `replication_instance`.

These alarms evaluate 3 of 5 periods, because AWS notes that CDC latency spikes are normal during batch work and
only sustained latency matters. A task that is stopped publishes no latency, which counts as not breaching, so
use a DMS event subscription for task state. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Set the module-wide defaults, then override per resource; an omitted field uses the default:

```hcl
module "alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-dms-alarms/v0.1.0"

  name_prefix = "team-prod"

  replication_instances = {
    my-instance = {}
  }

  replication_tasks = {
    "arn:aws:dms:eu-west-1:111111111111:task:ABCDEFGHIJKLMNOPQRSTUVWXYZ" = {
      replication_instance       = "my-instance"
      cdc_latency_target_seconds = 900
    }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Missing data counts as not breaching. Names: `<name_prefix>-dms-<instance>-<cpu|free-storage>` and `<name_prefix>-dms-<task id>-<cdc-latency-source|cdc-latency-target>`. Source: DMS user guide, "Monitoring AWS DMS tasks" (replication instance and task metrics).
