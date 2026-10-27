output "id" {
  description = "ID of the service control policy."
  value       = aws_organizations_policy.this.id
}

output "arn" {
  description = "ARN of the service control policy."
  value       = aws_organizations_policy.this.arn
}

output "target_ids" {
  description = "IDs of the root, OUs and accounts the policy is attached to."
  value       = sort([for a in aws_organizations_policy_attachment.this : a.target_id])
}
