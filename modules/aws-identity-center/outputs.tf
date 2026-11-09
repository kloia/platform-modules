output "instance_arn" {
  description = "ARN of the IAM Identity Center instance."
  value       = local.instance_arn
}

output "identity_store_id" {
  description = "ID of the identity store attached to the instance."
  value       = local.identity_store_id
}

output "user_ids" {
  description = "Map of user name to user ID, for users created by this call."
  value       = { for k, v in aws_identitystore_user.this : k => v.user_id }
}

output "group_ids" {
  description = "Map of group display name to group ID, for groups created by this call."
  value       = { for k, v in aws_identitystore_group.this : k => v.group_id }
}

output "group_membership_ids" {
  description = "Map of \"group/user\" to membership ID."
  value       = { for k, v in aws_identitystore_group_membership.this : k => v.membership_id }
}

output "permission_set_arns" {
  description = "Map of permission set name to ARN, for permission sets created by this call."
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "inline_policy_ids" {
  description = "Map of permission set name to inline policy resource ID."
  value       = { for k, v in aws_ssoadmin_permission_set_inline_policy.this : k => v.id }
}

output "managed_policy_attachment_ids" {
  description = "Map of \"permission_set/policy_arn\" to managed policy attachment ID."
  value       = { for k, v in aws_ssoadmin_managed_policy_attachment.this : k => v.id }
}

output "customer_managed_policy_attachment_ids" {
  description = "Map of \"permission_set/policy_name\" to customer managed policy attachment ID."
  value       = { for k, v in aws_ssoadmin_customer_managed_policy_attachment.this : k => v.id }
}

output "permissions_boundary_attachment_ids" {
  description = "Map of permission set name to permissions boundary attachment ID."
  value       = { for k, v in aws_ssoadmin_permissions_boundary_attachment.this : k => v.id }
}

output "account_assignment_ids" {
  description = "Map of \"PRINCIPAL_TYPE:principal/permission_set/account_id\" to account assignment ID."
  value       = { for k, v in aws_ssoadmin_account_assignment.this : k => v.id }
}

output "resolved_user_ids" {
  description = "Map of user name to user ID for created and looked-up (existing_users) users."
  value       = local.user_ids
}

output "resolved_group_ids" {
  description = "Map of group name to group ID for created and looked-up (existing_groups) groups."
  value       = local.group_ids
}

output "resolved_permission_set_arns" {
  description = "Map of permission set name to ARN for created and looked-up (existing_permission_sets) permission sets."
  value       = local.permission_set_arns
}
