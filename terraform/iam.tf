# ---------------------------------------------------------------
# IAM - Task Execution Role (used by ECS agent to pull ECR, write logs)
# ---------------------------------------------------------------

data "aws_iam_policy_document" "task_execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.project_name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume.json
}

resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow task execution role to read ECR + write to CloudWatch Logs (managed policy covers most)

# ---------------------------------------------------------------
# IAM - Task Role (used by the application at runtime)
# ---------------------------------------------------------------

resource "aws_iam_role" "task" {
  name               = "${var.project_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume.json
}

# Attach custom policies to task role if needed (e.g. read S3, write to DB).
# Left empty for now so the role has zero permissions by default.

# ---------------------------------------------------------------
# IAM - GitHub Actions OIDC Role (keyless CI/CD)
# ---------------------------------------------------------------

variable "github_org" {
  description = "GitHub organization or user that owns the repository"
  type        = string
  default     = "dhayaec"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "contacts-app"
}

# Create the GitHub OIDC provider if it doesn't already exist
# (idempotent — safe to run even if already present)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  thumbprint_list = [
    # GitHub's OIDC root CA thumbprint (valid through 2035)
    "1b511abead59c6ce207077c0bf9e4e63163ee558",
  ]

  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubActionsOIDC"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

# Permissions the workflow needs: ECR push, ECS update, ALB updates, S3/DynamoDB
# for Terraform state. Tighten later with explicit resources.
data "aws_iam_policy_document" "github_actions_inline" {
  statement {
    sid    = "ECR"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECS"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
      "ecs:DescribeClusters",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:ListTaskDefinitions",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ELB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    # Lock down to only the two roles this stack creates; the ECS agent
    # needs to assume the execution role on behalf of the task.
    resources = [
      aws_iam_role.task_execution.arn,
      aws_iam_role.task.arn,
    ]
  }

  statement {
    sid    = "Logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Infrastructure"
    effect = "Allow"
    actions = [
      "ec2:*",
      "iam:CreateRole",
      "iam:CreateOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetOpenIDConnectProvider",
      "iam:CreatePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:CreateInstanceProfile",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "TerraformStateS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-tfstate",
      "arn:aws:s3:::${var.project_name}-tfstate/*",
    ]
  }

  statement {
    sid    = "TerraformStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/${var.project_name}-tflock",
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_inline" {
  name   = "GitHubActionsOIDCInline"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_inline.json
}

output "github_actions_role_arn" {
  description = "ARN of the role to set in GitHub secret AWS_ACCOUNT_ID is NOT needed; copy this full ARN if you prefer to pin it."
  value       = aws_iam_role.github_actions.arn
}
