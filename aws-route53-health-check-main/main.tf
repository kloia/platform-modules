locals {
  http_enabled  = !var.disable && contains(var.health_check_type, "HTTP")
  https_enabled = !var.disable && contains(var.health_check_type, "HTTPS")
  tcp_enabled   = !var.disable && contains(var.health_check_type, "TCP")
}


resource "aws_route53_health_check" "http" {
  fqdn              = var.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = var.health_check_path
  failure_threshold = var.failure_threshold
  request_interval  = var.request_interval
  regions           = var.health_check_regions
  measure_latency   = true
  count             = local.http_enabled ? 1 : 0

  tags = {
    Name        = "${var.dns_name}-http"
    Environment = var.environment
    Automation  = "Terraform"
  }
}

resource "aws_route53_health_check" "https" {
  fqdn              = var.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.health_check_path
  failure_threshold = var.failure_threshold
  request_interval  = var.request_interval
  regions           = var.health_check_regions
  measure_latency   = true
  count             = local.https_enabled ? 1 : 0

  tags = {
    Name        = "${var.dns_name}-https"
    Environment = var.environment
    Automation  = "Terraform"
  }
}

resource "aws_route53_health_check" "tcp" {
  fqdn              = var.dns_name
  port              = var.port
  type              = "TCP"
  resource_path     = var.health_check_path
  failure_threshold = var.failure_threshold
  request_interval  = var.request_interval
  regions           = var.health_check_regions
  measure_latency   = true
  count             = local.tcp_enabled ? 1 : 0

  tags = {
    Name        = "${var.dns_name}-tcp"
    Environment = var.environment
    Automation  = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "http" {
  provider = aws.us-east-1

  alarm_name        = "${var.dns_name}-status-http${var.alarm_name_suffix}"
  alarm_description = "Route53 health check status for ${var.dns_name}"
  count             = (local.http_enabled && var.enable_cloudwatch_alarm) ? 1 : 0


  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"

  dimensions = {
    HealthCheckId = aws_route53_health_check.http[0].id
  }

  comparison_operator = "LessThanThreshold"
  statistic           = "Minimum"
  threshold           = "1"

  evaluation_periods = "1"
  period             = "60"

  alarm_actions             = var.alarm_actions
  ok_actions                = var.alarm_actions
  insufficient_data_actions = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "https" {
  provider = aws.us-east-1

  alarm_name        = "${var.dns_name}-status-https${var.alarm_name_suffix}"
  alarm_description = "Route53 health check status for ${var.dns_name}"
  count             = (local.https_enabled && var.enable_cloudwatch_alarm) ? 1 : 0

  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"

  dimensions = {
    HealthCheckId = aws_route53_health_check.https[0].id
  }

  comparison_operator = "LessThanThreshold"
  statistic           = "Minimum"
  threshold           = "1"

  evaluation_periods = "1"
  period             = "60"

  alarm_actions             = var.alarm_actions
  ok_actions                = var.alarm_actions
  insufficient_data_actions = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "tcp" {
  provider = aws.us-east-1

  alarm_name        = "${var.dns_name}-status-tcp${var.alarm_name_suffix}"
  alarm_description = "Route53 health check status for ${var.dns_name}"
  count             = (local.tcp_enabled && var.enable_cloudwatch_alarm) ? 1 : 0

  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"

  dimensions = {
    HealthCheckId = aws_route53_health_check.tcp[0].id
  }

  comparison_operator = "LessThanThreshold"
  statistic           = "Minimum"
  threshold           = "1"

  evaluation_periods = "1"
  period             = "60"

  alarm_actions             = var.alarm_actions
  ok_actions                = var.alarm_actions
  insufficient_data_actions = var.alarm_actions
}

