# Runbook: SQS queue alarms

Alarms from `aws-cloudwatch-sqs-alarms`, one per queue, typically on dead-letter queues. Name: `<name_prefix>-sqs-<queue>-messages`. The metric is either `visible` (`ApproximateNumberOfMessagesVisible`, for a queue that should be empty) or `sent` (`NumberOfMessagesSent`, for a queue the application writes to directly and drains continuously). The alarm description states which and the threshold.

> **Diagnose read-only first.** Purging a queue or redriving messages cannot be undone for purged messages. Agree it with the queue's owner.

```bash
P=<your-aws-profile>
R=<region>
Q=<queue-name>
URL=$(aws sqs get-queue-url --profile $P --region $R --queue-name $Q --query QueueUrl --output text)
```

## Messages in the queue

**Meaning.** At least the threshold number of messages is waiting in (`visible`) or was written to (`sent`) the queue within one period. On a dead-letter queue this means messages failed processing in the source queue and were set aside. A message that sits unprocessed in a dead-letter queue is lost work.

**Diagnose** (read-only):

```bash
aws sqs get-queue-attributes --profile $P --region $R --queue-url "$URL" \
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible MessageRetentionPeriod RedrivePolicy
aws sqs list-dead-letter-source-queues --profile $P --region $R --queue-url "$URL"
```

Read one message without removing it (it becomes invisible for 30 s, then returns):

```bash
aws sqs receive-message --profile $P --region $R --queue-url "$URL" \
  --max-number-of-messages 1 --visibility-timeout 30 --attribute-names All --message-attribute-names All
```

The source queue names come from `list-dead-letter-source-queues`; the consumer's logs for the time of the first failed message show why it was rejected.

**Causes.**

1. A consumer bug or a malformed message: after the fix, redrive the messages to the source queue (console: queue > Start DLQ redrive).
2. A downstream dependency was down during processing: once it is back, redrive.
3. Messages are about to expire: compare the oldest message's age with `MessageRetentionPeriod`; expired messages are gone, so redrive or save them first.

> **State-modifying, only with the owner's agreement:** `aws sqs purge-queue` and DLQ redrive.

## Silencing

The alarm returns to OK when the queue is below the threshold again. Do not disable it; change `messages_threshold` for that queue through a pull request.
