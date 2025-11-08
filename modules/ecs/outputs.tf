output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "Name of the ECS cluster."
}

output "service_name" {
  value       = aws_ecs_service.this.name
  description = "Name of the ECS service."
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN of the task definition."
}

output "task_definition_family" {
  value       = aws_ecs_task_definition.this.family
  description = "Family (name) of the task definition."
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution.arn
  description = "ARN of the ECS task execution role."
}

output "task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "ARN of the application task role."
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.this.name
  description = "Name of the log group for container logs."
}

output "security_group_id" {
  value       = aws_security_group.tasks.id
  description = "Security group protecting ECS tasks."
}
