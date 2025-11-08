output "alb_url" {
  description = "Public HTTP endpoint for the Application Load Balancer."
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "task_definition_name" {
  description = "Family/name of the ECS task definition."
  value       = module.ecs.task_definition_family
}

output "iam_role_arns" {
  description = "IAM roles used by the ECS task execution and application containers."
  value = {
    task_execution = module.ecs.task_execution_role_arn
    task           = module.ecs.task_role_arn
  }
}
