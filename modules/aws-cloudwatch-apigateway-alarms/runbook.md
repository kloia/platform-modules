# Runbook: API Gateway 5XX alarms

Alarms from `aws-cloudwatch-apigateway-alarms`, one per API. Name: `<name_prefix>-apigw-<api>-5xx-rate`. Condition: `5XXError / Count` above the threshold for 3 of 3 periods, only when there are at least `min_requests` per period. The alarm description states the values.

> **Diagnose read-only first.** Redeploying a stage or changing an integration affects every client of the API. Agree it with the API's owner.

```bash
P=<your-aws-profile>
R=<region>
```

## 5XX rate high

**Meaning.** The API returned 5XX (integration failure, integration timeout, or a gateway error) for more than the threshold share of requests for the whole window. `5XXError` counts what API Gateway returned to the client, whatever the cause behind it.

**Diagnose** (read-only). Separate gateway errors from backend errors:

```bash
aws cloudwatch get-metric-statistics --profile $P --region $R --namespace AWS/ApiGateway \
  --metric-name IntegrationLatency --dimensions Name=ApiName,Value=<api> \
  --start-time "$(date -u -v-3H +%Y-%m-%dT%H:%M:%SZ)" --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 300 --statistics Maximum --output table
aws apigateway get-stages --profile $P --region $R --rest-api-id <api-id> \
  --query 'item[].[stageName,deploymentId,lastUpdatedDate]' --output text
```

(On Linux replace `date -u -v-3H` with `date -u -d '3 hours ago'`.) Access logs for the stage, if enabled, show the status and integration status per request. A 504 with `IntegrationLatency` near the 29 s limit means the backend is too slow.

**Causes.**

1. The 5XX starts at a deployment (`lastUpdatedDate`): roll the stage back to the previous deployment.
2. The backend (Lambda, load balancer, HTTP service) fails or is slow: see its own alarm and logs.
3. Throttling or a quota on the backend integration: check the backend's throttle metrics.

> **State-modifying, only with the owner's agreement:** `aws apigateway update-stage` to point at a previous deployment.

## Silencing

The alarm returns to OK by itself. Do not disable it; change `error_rate_threshold` for that API through a pull request.
