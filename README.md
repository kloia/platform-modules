# aws-cloudwatch-dynamodb-alarms

Read and write throttle alarms for DynamoDB tables, looked up by name.

Up to two alarms per table, each firing when the metric reaches its threshold (default 1) in one period:

- **read throttle**: `ReadThrottleEvents`, Sum
- **write throttle**: `WriteThrottleEvents`, Sum

Both metrics are published on the `TableName` dimension, which covers the table itself and **not** its global
secondary indexes (AWS reports those only with `GlobalSecondaryIndexName`), so a throttled index is not seen
here. A single request can produce several throttle events (a batch read counts one per item), so the count is
not the number of failed requests. Set `enable_read_throttle_alarm` or `enable_write_throttle_alarm` to `false`
to create only one of the two. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Set the module-wide defaults, then override per resource; an omitted field uses the default:

```hcl
module "alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-dynamodb-alarms/v0.1.0"

  name_prefix = "team-prod"

  tables = {
    orders   = {}                                  # 1 event
    sessions = { read_throttle_threshold = 50 }    # tolerates a few
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Missing data counts as not breaching. Names: `<name_prefix>-dynamodb-<table>-<read-throttle|write-throttle>`. Source: DynamoDB developer guide, "DynamoDB metrics and dimensions".
