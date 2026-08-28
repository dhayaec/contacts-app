# ---------------------------------------------------------------
# Main - compose modules (simple flat composition for this size)
# ---------------------------------------------------------------

# VPC + networking already applied in network.tf
# ECR applied in ecr.tf
# ALB applied in alb.tf
# ECS applied in ecs.tf
# IAM applied in iam.tf
# Data sources for AZ list

locals {
  # AZ list driven by variable so plan/apply work without DescribeAvailabilityZones permission.
  availability_zones = var.availability_zones
}
