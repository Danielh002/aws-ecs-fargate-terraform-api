variable "region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name for the project, used as a prefix in resource names."
  type        = string
  default     = "node-api"
}

variable "environment" {
  description = "Environment tag applied to all resources."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag applied to all resources."
  type        = string
  default     = "platform-team"
}

variable "additional_tags" {
  description = "Optional additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones to use for subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet egress. Defaults to false to minimize cost."
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path ALB uses for health checks."
  type        = string
  default     = "/"
}

variable "assign_public_ip" {
  description = "Assign a public IP to the Fargate tasks (avoids NAT charges when true)."
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "Desired number of tasks in the ECS service."
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Container image for the Node.js API."
  type        = string
  default     = "public.ecr.aws/docker/library/node:18-alpine"
}

variable "container_port" {
  description = "Application port exposed by the container."
  type        = number
  default     = 3000
}

variable "task_cpu" {
  description = "CPU units for the Fargate task definition."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory (MB) for the Fargate task definition."
  type        = number
  default     = 512
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention in days."
  type        = number
  default     = 14
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for ECS service auto scaling."
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for ECS service auto scaling."
  type        = number
  default     = 2
}

variable "autoscaling_cpu_threshold" {
  description = "Target CPU utilization percentage for auto scaling."
  type        = number
  default     = 60
}
