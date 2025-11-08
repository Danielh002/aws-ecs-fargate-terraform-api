output "alb_arn" {
  value       = aws_lb.this.arn
  description = "ARN of the Application Load Balancer."
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "Public DNS name of the ALB."
}

output "listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "ARN of the HTTP listener."
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "ARN of the target group for the ECS service."
}

output "security_group_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID attached to the ALB."
}
