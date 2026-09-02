output "shield" {
  value       = { for key, value in aws_shield_protection.shield : key => value }
  description = "A map of properties for the created AWS Shield protection."
}

output "cross_account_shield" {
  value       = { for key, value in aws_shield_protection.cross_account_shield : key => value }
  description = "A map of properties for the created AWS Shield protection."
}