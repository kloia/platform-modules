provider "aws" {
  region = "eu-west-1"

  # Lets the example plan offline, with no credentials.
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_sns_topic" "alarms" {
  name = "network-alarms"
}

module "site_to_site_vpn" {
  source = "../../"

  name = "prod-partner"

  # Placeholder values throughout: 203.0.113.0/24 is the RFC 5737 documentation range.
  customer_gateway_ip_address = "203.0.113.10"

  transit_gateway_id             = "tgw-0123456789abcdef0"
  transit_gateway_route_table_id = "tgw-rtb-0123456789abcdef0"
  remote_cidrs                   = ["172.31.100.0/24"]

  tunnel_options = {
    ike_versions                 = ["ikev2"]
    phase1_encryption_algorithms = ["AES256", "AES256-GCM-16"]
    phase1_integrity_algorithms  = ["SHA2-256", "SHA2-384"]
    phase1_dh_group_numbers      = [14, 19, 20]
    phase2_encryption_algorithms = ["AES256", "AES256-GCM-16"]
    phase2_integrity_algorithms  = ["SHA2-256", "SHA2-384"]
    phase2_dh_group_numbers      = [14, 19, 20]
    dpd_timeout_action           = "restart"
    startup_action               = "start"
  }

  tunnel_alarm_actions         = [aws_sns_topic.alarms.arn]
  tunnel_alarm_actions_enabled = false

  tags = {
    Environment = "prod"
  }
}

output "tunnel_addresses" {
  value = [module.site_to_site_vpn.tunnel1_address, module.site_to_site_vpn.tunnel2_address]
}
