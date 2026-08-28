# ---------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "HTTP URL to reach the deployed application"
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for image pushes"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS Fargate cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS Fargate service"
  value       = aws_ecs_service.app.name
}
