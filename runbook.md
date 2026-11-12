# Runbook: Network Load Balancer alarms

Alarms from `aws-cloudwatch-nlb-alarms`. Names: `<name_prefix>-nlb-<load balancer>-unhealthy-hosts`, `-no-healthy-hosts` and `-port-allocation-errors`. The alarm description states the thresholds.

> **Diagnose read-only first.** Deregistering targets or changing health checks changes which targets receive traffic. Agree it with the owner.

```bash
P=<your-aws-profile>
R=<region>
TG=<target-group-arn>
```

## Unhealthy or no healthy hosts

**Meaning.** Targets of a target group fail their health check on every load balancer node (`unhealthy-hosts`), or too few (or none) are healthy or registered (`no-healthy-hosts`).

**Diagnose** (read-only):

```bash
aws elbv2 describe-target-health --profile $P --region $R --target-group-arn "$TG" \
  --query 'TargetHealthDescriptions[].[Target.Id,Target.Port,TargetHealth.State,TargetHealth.Reason,TargetHealth.Description]' --output table
aws elbv2 describe-target-groups --profile $P --region $R --target-group-arns "$TG" \
  --query 'TargetGroups[].[HealthCheckProtocol,HealthCheckPort,HealthCheckIntervalSeconds,UnhealthyThresholdCount]' --output text
```

**Causes.**

1. The service on the target is down, or the health check port is closed: check the target.
2. A security group or network ACL change blocks the health check.
3. Targets were deregistered or the autoscaling group scaled in: `no-healthy-hosts` fires on a target group without targets.

## Port allocation errors

**Meaning.** The load balancer could not allocate an ephemeral port while translating a client address, so client connections are dropped. Too many simultaneous connections or connections per minute to one target.

**Diagnose** (read-only): `ActiveFlowCount` and `NewFlowCount` per target group in the same window. **Fix:** add targets to the target group, so the connections spread over more addresses and ports.

> **State-modifying, only with the owner's agreement:** `aws elbv2 register-targets`, `deregister-targets`, health check changes.

## Silencing

An alarm returns to OK by itself. Do not disable one; change the threshold through a pull request.
