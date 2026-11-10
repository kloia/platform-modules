# aws-cloudwatch-cloudfront-alarms

5XX-rate alarm for CloudFront distributions, looked up by ID. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

One alarm per distribution: the `5xxErrorRate` metric (percentage of all viewer requests answered with 5XX), default above 5% for 3 of 3 periods of 5 minutes. The rate counts as 0 below `min_requests` (default 100) per period, so a few errors on a distribution with almost no traffic do not alarm. A distribution that never reaches `min_requests` cannot alarm at all: leave it out.

**Region.** CloudFront publishes its metrics in `us-east-1` only. Configure the AWS provider passed to this module for that region, and use SNS topics in the same region. The plan fails with a clear error in any other region, because an alarm there would stay green and never fire.

`5xxErrorRate` and `Requests` are default metrics, free for every distribution; no additional metrics subscription is needed. `5xxErrorRate` is averaged over the period, which weights each one-minute sample equally, not each request.

## Usage

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "cloudfront_alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source    = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-cloudfront-alarms/v0.1.0"
  providers = { aws = aws.us_east_1 }

  name_prefix = "team-prod"

  distributions = {
    website = { id = "E1ABCDEFGHIJKL" }                           # 5% default
    cms     = { id = "E2ABCDEFGHIJKL", error_rate_threshold = 2 } # tighter
  }

  alarm_actions = [aws_sns_topic.alerts_us_east_1.arn]
  ok_actions    = [aws_sns_topic.alerts_us_east_1.arn]
}
```

Missing data counts as not breaching. Names: `<name_prefix>-cloudfront-<label>-5xx-rate`.

Sources: CloudFront developer guide, "View CloudFront and edge function metrics", keywords *"The percentage of all viewer requests for which the response's HTTP status code is `5xx`"* and *"You must use the US East (N. Virginia) Region to view the graphs in the CloudWatch console"*. The `Region = Global` dimension was checked against live metrics, not against the documentation.
