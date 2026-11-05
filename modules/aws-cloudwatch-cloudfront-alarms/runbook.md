# Runbook: CloudFront alarms

Alarms from `aws-cloudwatch-cloudfront-alarms`, per distribution. Name: `<name_prefix>-cloudfront-<label>-5xx-rate`. Condition: the 5XX share of viewer requests above the threshold for 3 of 3 periods of 5 minutes, only with enough requests in the period. The alarm description states the values.

> **Diagnose read-only first.** Invalidations and origin changes affect every viewer of the distribution. Agree them with the owner.

```bash
P=<your-aws-profile>
D=<distribution-id>
```

## 5XX rate high

**Meaning.** CloudFront returned 5XX to viewers: the origin failed (502, 503, 504), an edge function failed, or CloudFront could not reach the origin.

**Diagnose** (read-only):

```bash
aws cloudfront get-distribution --profile $P --id $D \
  --query 'Distribution.[Status,DistributionConfig.Origins.Items[].DomainName]' --output text
aws cloudwatch get-metric-statistics --profile $P --region us-east-1 --namespace AWS/CloudFront \
  --metric-name 5xxErrorRate --dimensions Name=DistributionId,Value=$D Name=Region,Value=Global \
  --start-time "$(date -u -v-3H +%Y-%m-%dT%H:%M:%SZ)" --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 300 --statistics Average --output table
```

(On Linux replace `date -u -v-3H` with `date -u -d '3 hours ago'`.) Then check the origin itself (an S3 bucket, a load balancer, a cluster) and its alarms. The per-status-code rates (502, 503, 504) need the additional metrics subscription, which this module does not enable.

**Causes.**

1. The origin is down or slow: fix the origin; the alarm clears on its own.
2. An origin access or bucket policy change started refusing CloudFront.
3. A recent change to the distribution (check `LastModifiedTime`) or to an attached function.

## Silencing

The alarm returns to OK by itself. Do not disable it; change `error_rate_threshold` or `min_requests` through a pull request.
