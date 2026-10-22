# aws-cloudwatch-elasticache-alarms

Alarms for one ElastiCache (Redis OSS / Valkey) replication group, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

The group's member nodes are read from AWS on every plan, so a replica or shard added later is covered
on the next apply. Each alarm takes the worst node, which keeps it valid after a primary failover.

| Alarm | Default |
|---|---|
| `engine-cpu-high` | engine thread CPU above 80% |
| `memory-high` | memory above 85% of maxmemory |
| `evictions-high` | any key evicted, for every evaluated period |
| `rejected-connections-high` | any connection rejected (maxclients reached), for every evaluated period |
| `replication-lag-high` | a replica more than 30 s behind the primary |
| `host-cpu-high` | host CPU above `host_cpu_threshold`; off unless set |

For nodes with 2 vCPUs or fewer AWS recommends watching host CPU at 90% of one core, i.e. 90 divided by the
vCPU count ([Which metrics should I monitor?](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/CacheMetrics.WhichShouldIMonitor.html)).
On burstable (t-family) nodes this also catches CPU credit exhaustion.

Every threshold, the period and the datapoints are variables. Defaults: 5-minute period, 3 of 3 datapoints.

## Usage

```hcl
module "redis_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-elasticache-alarms?ref=module/aws-cloudwatch-elasticache-alarms/v0.1.0"

  name_prefix = "team-prod"
  name                 = "sessions"
  replication_group_id = "prod-sessions-redis"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-redis-<name>-<alarm>`.
