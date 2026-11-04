# Runbook: Step Functions alarms

Alarms from `aws-cloudwatch-stepfunctions-alarms`, per state machine. Names: `<name_prefix>-sfn-<name>-failed`, `-timed-out` and `-throttled`. Conditions: `ExecutionsFailed`, `ExecutionsTimedOut` or `ExecutionThrottled` at or above the threshold in a period. The alarm description states the values.

> **Diagnose read-only first.** Redriving or restarting executions re-runs steps that may already have had side effects. Agree it with the state machine's owner.

```bash
P=<your-aws-profile>
R=<region>
SM=<state-machine-arn>
```

## Failed executions

**Meaning.** One or more executions ended in a failure: a task state raised an error that no retry or catch handled.

**Diagnose** (read-only):

```bash
aws stepfunctions list-executions --profile $P --region $R --state-machine-arn $SM \
  --status-filter FAILED --max-results 5 \
  --query 'executions[].[name,startDate,stopDate]' --output text
aws stepfunctions describe-execution --profile $P --region $R --execution-arn <execution-arn> \
  --query '[status,error,cause]' --output text
```

The execution history (`get-execution-history`) shows the state that failed and its input.

**Causes.**

1. A task (Lambda, ECS, API call) failed: see that service's logs and alarm.
2. A bad input: the failed input is in the history; the producer needs fixing.
3. A permissions error (`AccessDeniedException`): the state machine's role lost or never had a permission.

## Timed out executions

**Meaning.** An execution exceeded the state machine's timeout. A state that waits for a callback or a task that never returns is the usual cause.

**Diagnose** (read-only): `list-executions --status-filter TIMED_OUT`, then the history of one execution to see which state was running when it timed out.

**Causes.**

1. A task is hung or very slow: see the task's own logs.
2. A callback token was never returned: the external system did not answer.

## Throttled

**Meaning.** State transitions or retries were throttled because the account's Step Functions rate limit was reached.

**Diagnose** (read-only): check `ExecutionThrottled` with the state machine's start rate, and the account's other state machines in the same window.

**Causes.**

1. A burst of executions: stagger the starts.
2. Another state machine uses the account's rate: look at `ExecutionsStarted` per state machine.
3. The limit is too low for the steady load: request a quota increase.

> **State-modifying, only with the owner's agreement:** `aws stepfunctions redrive-execution`, `start-execution`, `stop-execution`.

## Silencing

The alarm returns to OK by itself. Do not disable it; change the state machine's threshold through a pull request.
