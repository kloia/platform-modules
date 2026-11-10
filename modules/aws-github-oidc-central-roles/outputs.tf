output "plan_role_arn" {
  value       = aws_iam_role.plan.arn
  description = "ARN of the plan role."
}

output "plan_role_name" {
  value       = aws_iam_role.plan.name
  description = "Name of the plan role."
}

output "apply_role_arn" {
  value       = aws_iam_role.apply.arn
  description = "ARN of the apply role."
}

output "apply_role_name" {
  value       = aws_iam_role.apply.name
  description = "Name of the apply role."
}
