output "health_check_ids" {
  description = "The health check ID"
  value = compact([
    try(aws_route53_health_check.http[0].id, ""),
    try(aws_route53_health_check.https[0].id, ""),
    try(aws_route53_health_check.tcp[0].id, ""),
  ])
}

output "health_check_arns" {
  description = "The health check ARN"
  value = compact([
    try(aws_route53_health_check.http[0].arn, ""),
    try(aws_route53_health_check.https[0].arn, ""),
    try(aws_route53_health_check.tcp[0].arn, ""),
  ])
}
