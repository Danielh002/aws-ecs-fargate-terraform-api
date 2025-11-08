variable "project_name" {
  description = "Name prefix used for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "target_group_port" {
  description = "Port the target group forwards traffic to (container port)."
  type        = number
}

variable "health_check_path" {
  description = "HTTP path for ALB health checks."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
