#------------------------------------------------------------------------------
# AWS ECS SERVICE
#------------------------------------------------------------------------------
output "service_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the service."
  value       = aws_ecs_service.service.id
}

output "service_name" {
  description = "The name of the service."
  value       = aws_ecs_service.service.name
}

output "service_cluster" {
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = aws_ecs_service.service.cluster
}

output "desired_count" {
  description = "The number of instances of the task definition"
  value       = aws_ecs_service.service.desired_count
}