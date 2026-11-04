# Runbook: DynamoDB throttle alarms

Alarms from `aws-cloudwatch-dynamodb-alarms`, per table. Names: `<name_prefix>-dynamodb-<table>-read-throttle` and `-write-throttle`. Condition: `ReadThrottleEvents` or `WriteThrottleEvents` at or above the threshold in a period. The alarm description states the value.

> **Diagnose read-only first.** Changing a table's capacity mode or throughput is a billing and behaviour change. Agree it with the table's owner.

```bash
P=<your-aws-profile>
R=<region>
T=<table-name>
```

## Read or write throttling

**Meaning.** DynamoDB refused requests because they exceeded provisioned throughput, the on-demand limits or a single partition's limit. The SDK retries, so callers see added latency first and errors only when the retries run out.

**Diagnose** (read-only):

```bash
aws dynamodb describe-table --profile $P --region $R --table-name $T \
  --query 'Table.{Mode:BillingModeSummary.BillingMode,Read:ProvisionedThroughput.ReadCapacityUnits,Write:ProvisionedThroughput.WriteCapacityUnits,Items:ItemCount}'
aws application-autoscaling describe-scaling-policies --profile $P --region $R \
  --service-namespace dynamodb --resource-id table/$T --query 'ScalingPolicies[].PolicyName'
```

Compare `ConsumedReadCapacityUnits` / `ConsumedWriteCapacityUnits` with the provisioned values for the same window, and check `ThrottledRequests` per operation.

**Causes.**

1. Provisioned capacity is lower than the load and auto scaling reacts too slowly to a burst: raise the minimum capacity or move to on-demand.
2. One partition key is hot: consumed capacity is below the table total but throttling continues. The application must spread keys.
3. A new batch job or backfill: confirm with the owner and slow it down.

> **State-modifying, only with the owner's agreement:** `aws dynamodb update-table` (capacity or billing mode).

## Silencing

The alarm returns to OK by itself. Do not disable it; change the table's threshold through a pull request.
