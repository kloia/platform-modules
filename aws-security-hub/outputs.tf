##################################################
# Security Hub
##################################################
output "securityhub_account" {
  description = "Security Hub AWS account configuration."
  value       = aws_securityhub_account.this
}

output "finding_aggregator" {
  description = "Security Hub finding aggregator configuration."
  value       = aws_securityhub_finding_aggregator.this
}

##################################################
# Security Hub Subscriptions
##################################################
output "product_subscription" {
  description = "Security Hub products subscriptions."
  value       = aws_securityhub_product_subscription.this
}

output "standards_subscription" {
  description = "Security Hub compliance standards subscriptions."
  value       = aws_securityhub_standards_subscription.this
}

##################################################
# Security Hub Action Targets
##################################################
output "action_target" {
  description = "Security Hub custome action targets."
  value       = aws_securityhub_action_target.this
}

##################################################
# Security Hub Delegated Admin
##################################################
output "securityhub_delegated_admin_account" {
  description = "AWS Security Hub Delegated Admin account."
  value       = aws_securityhub_organization_admin_account.this
}

# output "securityhub_organization_configuration" {
#   description = "AWS Security Hub Organizations configuration."
#   value       = aws_securityhub_organization_configuration.this
# }

##################################################
# Security Hub Account Member
##################################################
output "securityhub_member" {
  description = "AWS Security Hub member configuration."
  value       = aws_securityhub_member.this
}

output "securityhub_member_account" {
  description = "AWS Security Hub member account configuration."
  value       = aws_securityhub_account.member
}

##################################################
# Security Hub Organizations Invite
##################################################
output "securityhub_member_invite" {
  description = "AWS Security Hub organizations invite."
  value       = aws_securityhub_invite_accepter.member
}