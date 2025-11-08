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
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
    },
    var.additional_tags,
  )
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
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
  project_name      = var.project_name
  target_group_port = var.container_port
  health_check_path = var.health_check_path
  tags              = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name            = "${var.project_name}-cluster"
  service_name            = "${var.project_name}-service"
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.public_subnet_ids
  assign_public_ip        = var.assign_public_ip
  desired_count           = var.desired_count
  container_image         = var.container_image
  container_port          = var.container_port
  cpu                     = var.task_cpu
  memory                  = var.task_memory
  log_retention_in_days   = var.log_retention_in_days
  target_group_arn        = module.alb.target_group_arn
  alb_security_group_id   = module.alb.security_group_id
  min_capacity            = var.autoscaling_min_capacity
  max_capacity            = var.autoscaling_max_capacity
  scale_cpu_threshold     = var.autoscaling_cpu_threshold
  environment             = var.environment
  region                  = var.region
  tags                    = local.common_tags
}
