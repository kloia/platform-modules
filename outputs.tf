output "vpn_endpoint_arn" {
  value       = local.enabled ? join("", aws_ec2_client_vpn_endpoint.default[*].arn) : null
  description = "The ARN of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_id" {
  value       = local.enabled ? join("", aws_ec2_client_vpn_endpoint.default[*].id) : null
  description = "The ID of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_dns_name" {
  value       = local.enabled ? join("", aws_ec2_client_vpn_endpoint.default[*].dns_name) : null
  description = "The DNS Name of the Client VPN Endpoint Connection."
}