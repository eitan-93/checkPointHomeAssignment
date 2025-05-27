# Create an IAM role for the GitHub Actions workflow
resource "aws_iam_role" "github_actions" {
  name        = "github-actions-role"
  description = "Role for GitHub Actions workflow"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "actions.githubusercontent.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

# Create an IAM policy for the GitHub Actions workflow
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-policy"
  description = "Policy for GitHub Actions workflow"

  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
        ]
        Effect = "Allow"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# Create GitHub Actions secrets
#resource "github_actions_secret" "aws_access_key_id" {
#  repository = var.repository
#  secret_name = var.aws_access_key_id_secret_name
#}

#resource "github_actions_secret" "aws_secret_access_key" {
#  repository = var.repository
#  secret_name = var.aws_secret_access_key_secret_name
#}

#resource "github_repository_file" "example-workflow" {
#  repository = var.repository
#  file       = ".github/workflows/example-workflow.yml"
#  content    = file("${path.module}/example-workflow.yml")
#}

resource "github_actions_secret" "aws_access_key_id" {
  repository = var.repository
  secret_name = var.aws_access_key_id_secret_name
  plaintext_value = "my-access-key-id"
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository = var.repository
  secret_name = var.aws_secret_access_key_secret_name
  plaintext_value = "my-secret-access-key"
}

# Use the secrets stored in the GitHub Secrets manager
# data "github_actions_secret" "aws_access_key_id" {
# name        = "AWS_ACCESS_KEY_ID_LOCALSTACK"
# repository  = "eitan-93/checkPointHomeAssignment"
#}

#data "github_actions_secret" "aws_secret_access_key" {
# name        = "AWS_SECRET_ACCESS_KEY_LOCALSTACK"
# repository  = "eitan-93/checkPointHomeAssignment"
#}