# aws-cloudwatch-acm-alarms

Expiry alarm for one ACM certificate, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

| Alarm | Default |
|---|---|
| `expiry` | fewer than 30 days to expiry |

ACM publishes `DaysToExpiry` twice a day for every certificate until it expires
([ACM metrics](https://docs.aws.amazon.com/acm/latest/userguide/cloudwatch-metrics.html)). ACM renews certificates
it issued, but not imported ones, so by default only `IMPORTED` certificates are matched. The certificate is
looked up by domain on every plan; re-importing into the same ARN keeps the alarm as it is.

## Usage

```hcl
module "certificate_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-acm-alarms?ref=module/aws-cloudwatch-acm-alarms/v0.1.0"

  name_prefix = "team-prod"
  name        = "wildcard"
  domain      = "*.example.com"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-acm-<name>-<alarm>`.
