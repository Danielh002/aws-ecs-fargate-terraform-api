terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  cluster_name    = "${var.project_name}-${var.environment}-cluster"

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
    },
    var.additional_tags,
  )
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = merge(local.common_tags, {
    Name = local.cluster_name
  })
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = local.resource_prefix
  vpc_cidr           = var.vpc_cidr
  azs                = var.azs
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  project_name      = local.resource_prefix
  target_group_port = var.frontend_container_port
  health_check_path = var.frontend_health_check_path
  tags              = local.common_tags
}

resource "aws_lb_target_group" "backend" {
  name        = "${local.resource_prefix}-backend-tg"
  port        = var.backend_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = var.backend_health_check_path
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-backend-tg"
  })
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = module.alb.listener_arn
  priority     = var.backend_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = var.backend_path_patterns
    }
  }
}

module "ecs_backend" {
  source = "./modules/ecs"

  cluster_name          = aws_ecs_cluster.this.name
  cluster_arn           = aws_ecs_cluster.this.arn
  service_name          = "${local.resource_prefix}-backend-service"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  assign_public_ip      = var.assign_public_ip
  desired_count         = var.backend_desired_count
  container_image       = var.backend_container_image
  container_port        = var.backend_container_port
  cpu                   = var.backend_task_cpu
  memory                = var.backend_task_memory
  log_retention_in_days = var.log_retention_in_days
  target_group_arn      = aws_lb_target_group.backend.arn
  alb_security_group_id = module.alb.security_group_id
  min_capacity          = var.backend_autoscaling_min_capacity
  max_capacity          = var.backend_autoscaling_max_capacity
  scale_cpu_threshold   = var.backend_autoscaling_cpu_threshold
  environment           = var.environment
  region                = var.region
  environment_variables = {
    FRONTEND_ORIGINS = join(
      ",",
      distinct(
        concat(
          var.backend_allowed_origins,
          ["http://${module.alb.alb_dns_name}"]
        )
      )
    )
  }
  tags                  = local.common_tags
}

module "ecs_frontend" {
  source = "./modules/ecs"

  cluster_name          = aws_ecs_cluster.this.name
  cluster_arn           = aws_ecs_cluster.this.arn
  service_name          = "${local.resource_prefix}-frontend-service"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  assign_public_ip      = var.assign_public_ip
  desired_count         = var.frontend_desired_count
  container_image       = var.frontend_container_image
  container_port        = var.frontend_container_port
  cpu                   = var.frontend_task_cpu
  memory                = var.frontend_task_memory
  log_retention_in_days = var.log_retention_in_days
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  min_capacity          = var.frontend_autoscaling_min_capacity
  max_capacity          = var.frontend_autoscaling_max_capacity
  scale_cpu_threshold   = var.frontend_autoscaling_cpu_threshold
  environment           = var.environment
  region                = var.region
  tags                  = local.common_tags
}
