# aws-cloudwatch-apigateway-alarms

5XX-rate alarms for API Gateway REST APIs. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

One alarm per API: `5XXError / Count`, default above 5% for 3 of 3 periods of 5 minutes. The rate counts as 0
below `min_requests` per period, so one error on idle traffic does not alarm. The `ApiName` dimension covers
every stage of the API.

Set the module-wide defaults, then override per API; an omitted field uses the default:

```hcl
module "apigw_alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-apigateway-alarms/v0.1.0"

  name_prefix          = "team-prod"
  error_rate_threshold = 5

  apis = {
    orders  = {}                                          # 5%
    billing = { error_rate_threshold = 2 }                # 2%
    admin   = { error_rate_threshold = 20, min_requests = 100 }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

`priority` (`P1` to `P5`, default none, module-wide with a per-API override) is written at the start of each alarm
description as `[P2]`. An Opsgenie CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets
the alert priority from it; without such a rule the prefix does nothing. With `priority` unset the description is
unchanged.

APIs are not looked up. API Gateway allows two REST APIs to share a name, and the metric dimension is the name,
so APIs with the same name are reported and alarmed on together. A misspelt name creates an alarm that never
receives data and stays `OK`. Alarm names: `<name_prefix>-apigw-<api>-5xx-rate`.

Source: API Gateway developer guide, "Amazon API Gateway dimensions and metrics" (5XXError, Count, ApiName).

## Anomaly alarm

`enable_anomaly_alarm` (default `false`; a API may turn it on or off with `anomaly_alarm`) adds a second alarm
per API on the same 5XX rate. It goes to `ALARM` when the rate stays above the range CloudWatch expects, using
[anomaly detection](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Create_Anomaly_Detection_Alarm.html):
the range is learned from the metric's own history and follows its hourly, daily and weekly pattern. `anomaly_band_width`
(default 3, per API override) is the width of the range in standard deviations; a larger value tolerates more deviation.

Use it for a API with a steady, known error rate, where no fixed threshold fits: a threshold above the usual rate hides a
moderate rise, one below it fires all the time. The fixed-threshold alarm is kept, because CloudWatch takes up to two weeks to
learn the range. Alarm name: `<name_prefix>-apigw-<api>-5xx-rate-anomaly`. The alarm is billed for the metrics it reads plus the upper and lower band.
