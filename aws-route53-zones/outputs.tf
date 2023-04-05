output "route53_zone_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = merge({ for k, v in aws_route53_zone.this : k => v.zone_id },{ for k, v in data.aws_route53_zone.this : k => v.zone_id })
}

output "route53_zone_zone_arn" {
  description = "Zone ID of Route53 zone"
  value       = merge({ for k, v in aws_route53_zone.this : k => v.arn },{ for k, v in data.aws_route53_zone.this : k => v.arn })
}

output "route53_zone_name_servers" {
  description = "Name servers of Route53 zone"
  value       = merge({ for k, v in aws_route53_zone.this : k => v.name_servers },{ for k, v in data.aws_route53_zone.this : k => v.name_servers })
}

output "route53_zone_name" {
  description = "Name of Route53 zone"
  value       = merge({ for k, v in aws_route53_zone.this : k => v.name },{ for k, v in data.aws_route53_zone.this : k => v.name })
}
