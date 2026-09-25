output "customer_gateway_id" {
  description = "Customer gateway ID."
  value       = aws_customer_gateway.this.id
}

output "vpn_connection_id" {
  description = "VPN connection ID."
  value       = aws_vpn_connection.this.id
}

output "transit_gateway_attachment_id" {
  description = "Transit gateway attachment ID of the VPN."
  value       = aws_vpn_connection.this.transit_gateway_attachment_id
}

output "tunnel1_address" {
  description = "AWS-side outside IP of tunnel 1, for the remote device."
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_address" {
  description = "AWS-side outside IP of tunnel 2, for the remote device."
  value       = aws_vpn_connection.this.tunnel2_address
}

output "tunnel1_inside_cidrs" {
  description = "Inside addresses of tunnel 1: AWS side and remote side."
  value = {
    aws    = aws_vpn_connection.this.tunnel1_vgw_inside_address
    remote = aws_vpn_connection.this.tunnel1_cgw_inside_address
  }
}

output "tunnel2_inside_cidrs" {
  description = "Inside addresses of tunnel 2: AWS side and remote side."
  value = {
    aws    = aws_vpn_connection.this.tunnel2_vgw_inside_address
    remote = aws_vpn_connection.this.tunnel2_cgw_inside_address
  }
}

output "tunnel_log_group_name" {
  description = "Name of the created tunnel log group, or null."
  value       = try(aws_cloudwatch_log_group.tunnel[0].name, null)
}

output "tunnel_alarm_arns" {
  description = "TunnelState alarm ARNs by tunnel."
  value       = { for k, a in aws_cloudwatch_metric_alarm.tunnel_state : k => a.arn }
}
