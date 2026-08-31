output "access_entries" {
  description = "Map of the created access entries, keyed as given in var.access_entries."
  value       = aws_eks_access_entry.this
}

output "access_entry_arns" {
  description = "Map of access entry key to the ARN of the access entry."
  value       = { for k, v in aws_eks_access_entry.this : k => v.access_entry_arn }
}

output "access_policy_associations" {
  description = "Map of the created access policy associations, keyed \"<entry key>_<policy key>\"."
  value       = aws_eks_access_policy_association.this
}
