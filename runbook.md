# Runbook: DMS alarms

Alarms from `aws-cloudwatch-dms-alarms`. Per replication instance: `<name_prefix>-dms-<instance>-cpu` and `-free-storage`. Per task: `<name_prefix>-dms-<task>-cdc-latency-source` and `-cdc-latency-target`. The alarm description states the thresholds.

> **Diagnose read-only first.** Stopping, restarting or resuming a task, or changing the instance, interrupts replication and can force a reload. Agree it with the owner of the source and target databases.

```bash
P=<your-aws-profile>
R=<region>
```

## CPU or free storage on the replication instance

**Meaning.** `cpu`: the instance's CPU reached the threshold for the whole window. `free-storage`: free space fell below the configured share of the instance's allocated storage. Task logs and cached changes fill it, and the instance stops at storage-full.

**Diagnose** (read-only):

```bash
aws dms describe-replication-instances --profile $P --region $R \
  --filters Name=replication-instance-id,Values=<instance> \
  --query 'ReplicationInstances[0].[ReplicationInstanceStatus,ReplicationInstanceClass,AllocatedStorage]' --output text
aws dms describe-replication-tasks --profile $P --region $R \
  --filters Name=replication-instance-arn,Values=<instance-arn> \
  --query 'ReplicationTasks[].[ReplicationTaskIdentifier,Status,ReplicationTaskStats.FullLoadProgressPercent]' --output text
```

**Causes.**

1. A full load or a large change burst runs: CPU clears when it finishes.
2. A task is stuck or erroring and keeps writing logs or cached changes: check its CloudWatch log group for the error.
3. The instance is too small for its tasks: the owner resizes the instance class or storage.

## CDC latency

**Meaning.** `source`: changes are captured late from the source database. `target`: captured changes are applied late to the target. Latency is in seconds.

**Diagnose** (read-only):

```bash
aws dms describe-replication-tasks --profile $P --region $R \
  --filters Name=replication-task-id,Values=<task> \
  --query 'ReplicationTasks[0].[Status,LastFailureMessage,StopReason]' --output text
```

Task log group: `dms-tasks-<instance>`. Compare source latency with the source database's write load, and target latency with the target's CPU, locks and connection count.

**Causes.**

1. Source latency alone: the source is slow to read its log (a large transaction, or a replication slot that cannot advance). Check the source database.
2. Target latency alone: the target applies slowly (locks, missing index, throttling). Check the target database.
3. Both together: the instance is overloaded; see the CPU section.

> **State-modifying, only with the owner's agreement:** `aws dms stop-replication-task`, `start-replication-task`, instance modification.

## Silencing

The alarm returns to OK by itself. Do not disable it; change the instance's or task's threshold through a pull request.
