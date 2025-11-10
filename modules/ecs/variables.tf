variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster this service should register with."
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service and task family."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the service runs."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for ECS tasks."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IPs to tasks to avoid NAT charges."
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "Desired number of tasks in the service."
  type        = number
}

variable "container_image" {
  description = "Container image for the Node.js API."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container."
  type        = number
}

variable "cpu" {
  description = "CPU units for the task definition."
  type        = number
}

variable "memory" {
  description = "Memory (MB) for the task definition."
  type        = number
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention."
  type        = number
}

variable "target_group_arn" {
  description = "ARN of the target group the service registers with."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB to allow ingress from."
  type        = string
}

variable "min_capacity" {
  description = "Minimum tasks for auto scaling."
  type        = number
}

variable "max_capacity" {
  description = "Maximum tasks for auto scaling."
  type        = number
}

variable "scale_cpu_threshold" {
  description = "Target CPU utilization percentage for scaling."
  type        = number
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
}

variable "region" {
  description = "AWS region, required for logs configuration."
  type        = string
}

variable "environment_variables" {
  description = "Additional environment variables to inject into the container."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to all ECS resources."
  type        = map(string)
  default     = {}
}
