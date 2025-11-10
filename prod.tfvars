region       = "us-east-1"
project_name = "expenses-tracker"
environment  = "prod"
owner        = "platform-team"

backend_container_image   = "public.ecr.aws/docker/library/node:18-alpine"
backend_container_port    = 3000
backend_health_check_path = "/health"
backend_allowed_origins   = []

frontend_container_image   = "public.ecr.aws/nginx/nginx:stable-alpine"
frontend_container_port    = 80
frontend_health_check_path = "/"
backend_path_patterns      = ["/api/*"]
backend_listener_priority  = 10

assign_public_ip      = true
enable_nat_gateway    = false
log_retention_in_days = 30

# Backend sizing (slightly higher but still low cost)
backend_desired_count             = 1
backend_task_cpu                  = 512
backend_task_memory               = 1024
backend_autoscaling_min_capacity  = 1
backend_autoscaling_max_capacity  = 2
backend_autoscaling_cpu_threshold = 55

# Frontend sizing
frontend_desired_count             = 1
frontend_task_cpu                  = 256
frontend_task_memory               = 512
frontend_autoscaling_min_capacity  = 1
frontend_autoscaling_max_capacity  = 2
frontend_autoscaling_cpu_threshold = 55

vpc_cidr        = "10.0.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
