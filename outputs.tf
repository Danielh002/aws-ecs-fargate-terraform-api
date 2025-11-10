output "alb_url" {
  description = "Public HTTP endpoint for the shared Application Load Balancer."
  value       = "http://${module.alb.alb_dns_name}"
}

output "backend_ecs_service" {
  description = "Key identifiers for the backend ECS deployment."
  value = {
    cluster_name         = module.ecs_backend.cluster_name
    service_name         = module.ecs_backend.service_name
    task_definition_name = module.ecs_backend.task_definition_family
    task_execution_role  = module.ecs_backend.task_execution_role_arn
    task_role            = module.ecs_backend.task_role_arn
    log_group_name       = module.ecs_backend.log_group_name
    task_security_group  = module.ecs_backend.security_group_id
  }
}

output "frontend_ecs_service" {
  description = "Key identifiers for the frontend ECS deployment."
  value = {
    cluster_name         = module.ecs_frontend.cluster_name
    service_name         = module.ecs_frontend.service_name
    task_definition_name = module.ecs_frontend.task_definition_family
    task_execution_role  = module.ecs_frontend.task_execution_role_arn
    task_role            = module.ecs_frontend.task_role_arn
    log_group_name       = module.ecs_frontend.log_group_name
    task_security_group  = module.ecs_frontend.security_group_id
  }
}
