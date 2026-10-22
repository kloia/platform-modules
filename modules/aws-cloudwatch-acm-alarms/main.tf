# Looked up by domain on every plan, so a certificate re-imported under a new ARN is picked up on the next apply.
data "aws_acm_certificate" "this" {
  domain      = var.domain
  types       = var.certificate_types
  statuses    = ["ISSUED"]
  most_recent = true
}

module "expiry" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  alarm_name        = "${var.name_prefix}-acm-${var.name}-expiry"
  alarm_description = join(" ", compact(["Certificate ${var.domain} expires in less than ${var.days_threshold} days. Imported certificates are not renewed by ACM: import the renewed certificate into the same ARN (ARN: ${data.aws_acm_certificate.this.arn}).", var.description_suffix]))

  namespace   = "AWS/CertificateManager"
  metric_name = "DaysToExpiry"
  statistic   = "Minimum"
  period      = 86400
  dimensions  = { CertificateArn = data.aws_acm_certificate.this.arn }

  comparison_operator = "LessThanThreshold"
  threshold           = var.days_threshold
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
