# Runbook: Lambda alarms

Alarms from `aws-cloudwatch-lambda-alarms`. Names: `<name_prefix>-lambda-<function>-<error-rate|throttles|duration>`. The alarm description in CloudWatch states the threshold in force for that function.

> **Diagnose read-only first.** Changing concurrency, timeout or code on a live function changes behaviour for every caller. Agree it with the function's owner.

| Alarm suffix | Condition | First response |
|---|---|---|
| `error-rate` | `Errors / Invocations` above the threshold for 3 of 3 periods, only when there are at least `min_invocations` per period | Read the function's error logs (section 1) |
| `throttles` | `Throttles` at or above the threshold in one period | A concurrency limit was reached (section 2) |
| `duration` | p99 `Duration` above a percentage of the function's own timeout for 3 of 3 periods | Invocations are close to being cut off (section 3) |

```bash
P=<your-aws-profile>
R=<region>
F=<function-name>
```

## 1. Error rate

**Meaning.** A share of invocations ended in an error (an exception, a timeout or an out-of-memory kill). A function with a known steady failure rate has its own threshold, so an alarm means the rate rose above that baseline.

**Diagnose** (read-only):

```bash
aws logs tail /aws/lambda/$F --profile $P --region $R --since 30m --filter-pattern '?ERROR ?Error ?Task timed out ?"Runtime exited"'
aws lambda get-function-configuration --profile $P --region $R --function-name $F \
  --query '{Timeout:Timeout,Memory:MemorySize,Runtime:Runtime,Modified:LastModified}'
```

**Causes.**

1. The errors start at the time of a deploy (`LastModified`): roll the code back or fix it.
2. A downstream dependency fails (database, API, queue): the log shows the failing call; see the alarm for that dependency.
3. `Task timed out` or `Runtime exited`: the timeout or memory is too low for the current input; see section 3.

## 2. Throttles

**Meaning.** Invocations were refused because the function or the account reached its concurrency limit. Synchronous callers receive an error; asynchronous events are retried and may be lost after the retry window.

**Diagnose** (read-only):

```bash
aws lambda get-function-concurrency --profile $P --region $R --function-name $F
aws lambda get-account-settings --profile $P --region $R \
  --query '{Limit:AccountLimit.ConcurrentExecutions,Unreserved:AccountLimit.UnreservedConcurrentExecutions}'
```

Compare with the `ConcurrentExecutions` metric for the function and for the account in the same window.

**Causes.**

1. The function has a reserved concurrency that is too low for a burst: the owner raises it.
2. Another function uses the account's concurrency: look at `ConcurrentExecutions` per function.
3. A retry storm: a failing downstream makes callers retry; fix the downstream first.

> **State-modifying, only with the owner's agreement:** `aws lambda put-function-concurrency` or a quota increase.

## 3. Duration close to the timeout

**Meaning.** The p99 duration is above the configured percentage of the function's timeout, so some invocations are about to be cut off. The timeout is read from the function on every plan.

**Diagnose** (read-only): the `Duration` p99 and max for the window, and the logs for the slowest invocations.

```bash
aws logs tail /aws/lambda/$F --profile $P --region $R --since 30m --filter-pattern '"REPORT RequestId"'
```

**Causes.**

1. A downstream call became slow: see its alarm.
2. The input grew (larger payloads, more records per batch): the owner reduces the batch or raises the timeout.
3. Memory is low for the workload (the REPORT line shows `Max Memory Used` near `Memory Size`): more memory also adds CPU.

## Silencing

An alarm returns to OK by itself. Do not disable one to quiet it; change the threshold in the calling configuration through a pull request, with the new baseline in the comment.
