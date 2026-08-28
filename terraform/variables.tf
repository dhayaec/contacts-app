variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used for resource naming"
  type        = string
  default     = "contacts-app"
}

variable "environment" {
  description = "Environment label (dev / staging / prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Team / owner identifier for cost tracking"
  type        = string
  default     = "platform-team"
}

variable "container_port" {
  description = "Port exposed by the Next.js container"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "CPU units for Fargate task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for Fargate task (MiB)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "image_tag" {
  description = "Docker image tag for deployment (set via CI/CD)"
  type        = string
  default     = "latest"
}

variable "enable_delete_protection" {
  description = "Enable delete protection on ECR repository"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of AZ names in the target region (must match your subnets count)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
