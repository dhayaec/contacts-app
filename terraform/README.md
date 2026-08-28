# Terraform - AWS Deployment for contacts-app

## Architecture

```
[ GitHub Actions ]
        |  (OIDC - no static keys)
        v
[ Amazon ECR ]  <-- docker push (image tag = commit SHA)
        |
        v
[ ECS Fargate Service ]  ---> [ CloudWatch Logs ]
        |
        v
[ Application Load Balancer (public) ] ---> [ Target Group: ECS tasks ]
```

Two public subnets host the ALB; two private subnets host ECS Fargate tasks. The NAT Gateway lets private tasks reach the ECR endpoint.

## Files

| File | Purpose |
|------|---------|
| `provider.tf` | Terraform + AWS provider config, optional S3 backend |
| `variables.tf` | All input variables (region, project, image_tag, sizing, etc.) |
| `outputs.tf` | Stack outputs (ALB URL, ECR URL, ECS service name) |
| `network.tf` | VPC, public/private subnets, NAT, route tables, SGs |
| `ecr.tf` | ECR repository with lifecycle policy + image scanning |
| `alb.tf` | Application Load Balancer + target group + listener |
| `iam.tf` | Task execution role (ECR + CloudWatch) and task role |
| `ecs.tf` | ECS cluster, task definition, Fargate service, log group |
| `main.tf` | Data sources, glue |

## Prerequisites

1. AWS account + IAM user able to create VPC, ECR, ECS, IAM resources
2. S3 bucket + DynamoDB table for Terraform state (one-time manual setup)
3. GitHub repo secrets (see OIDC section)

## State backend (recommended)

```bash
# Create the S3 bucket
aws s3api create-bucket \
  --bucket contacts-app-tfstate \
  --region us-east-1

# Create the lock table
aws dynamodb create-table \
  --table-name contacts-app-tflock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

# Then uncomment the backend block in provider.tf
```

## First deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply -var="image_tag=initial"
```

`terraform output alb_url` returns the public URL of the deployed app.

## Subsequent deploys

GitHub Actions handles everything once configured - just push to `main`.

## Teardown

```bash
cd terraform
terraform destroy
```

## Variable overrides

```bash
terraform apply \
  -var="environment=prod" \
  -var="desired_count=3" \
  -var="container_cpu=512" \
  -var="container_memory=1024" \
  -var="image_tag=abc1234"
```

## Notes

- Container port 3000 must match the Next.js `start` script (default in `package.json`).
- `desired_count` is set to 2 by default for high availability across 2 AZs.
- `image_tag` is injected by the GitHub Actions workflow on every push.
- CloudWatch log group retention: 7 days (adjust in `ecs.tf`).
