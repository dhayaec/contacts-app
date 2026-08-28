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
#
# The OIDC provider and GitHubActionsOIDC role are created once via the
# `bootstrap/` stack (out of band) because they must exist before the
# workflow can run terraform. This file no longer manages them.
# ---------------------------------------------------------------

# (Resources moved to terraform/bootstrap/)
