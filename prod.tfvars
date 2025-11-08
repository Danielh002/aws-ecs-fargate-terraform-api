region               = "us-east-1"
project_name         = "node-api"
environment          = "prod"
owner                = "platform-team"
container_image      = "public.ecr.aws/docker/library/node:18-alpine"
container_port       = 3000
assign_public_ip     = true
enable_nat_gateway   = false
health_check_path    = "/health"
log_retention_in_days = 30

task_cpu    = 512
task_memory = 1024

desired_count                  = 1
autoscaling_min_capacity       = 1
autoscaling_max_capacity       = 2
autoscaling_cpu_threshold      = 55

vpc_cidr        = "10.0.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
