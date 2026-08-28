# AWS OIDC + GitHub Actions Setup

This document explains how to configure secure, keyless authentication between GitHub Actions and AWS.

## Why OIDC?

Using OpenID Connect eliminates the need for long-lived AWS access keys (`AWS_ACCESS_KEY_ID` / secret). Instead, the GitHub Actions workflow requests a temporary session token directly from AWS STS by presenting the workflow's JWT identity token.

## 1. Create the IAM OIDC Provider (AWS Console / CLI)

```bash
# Create the provider for GitHub Actions in your account
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --thumbprint-list "1b511abead59c6ce207077c0bf9e4e63163ee558" \
  --client-id-list "sts.amazonaws.com"
```

## 2. Create the IAM Role for GitHub Actions

Replace `contacts-app-tfstate` / `contacts-app-tflock` with your bucket/table names.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<ORG>/<REPO>:*"
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

Attach policies covering ECR push, ECS update, ALB updates, and Terraform state access.

Simplified inline policy (add more permissions as needed):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "elasticloadbalancing:*",
        "ec2:*",
        "iam:PassRole",
        "logs:*",
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "*"
    }
  ]
}
```

## 3. Configure GitHub Secrets

In the repo settings (`Settings > Secrets and variables > Actions`):

| Secret | Value |
|--------|-------|
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account number |
| `TF_STATE_BUCKET` | `contacts-app-tfstate` |
| `TF_LOCK_TABLE` | `contacts-app-tflock` |

## 4. Verify

After pushing to `main`, the workflow `Terraform Apply` should complete without `AccessDenied` errors.
