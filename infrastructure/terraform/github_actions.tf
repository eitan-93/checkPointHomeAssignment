# Configure the AWS provider
provider "aws" {
  region = "us-east-2"
}

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
          Service = "github-actions.amazonaws.com"
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

# Create a GitHub Actions workflow that uses the AWS CLI with the assumed IAM role
resource "github_actions_workflow" "example" {
  name        = "example-workflow"
  repository  = "my-repo"
  workflow    = file("${path.module}/example-workflow.yml")
}

# Use the secrets stored in the GitHub Secrets manager
data "github_actions_secret" "aws_access_key_id" {
  name        = "AWS_ACCESS_KEY_ID_LOCALSTACK"
  repository  = "my-repo"
}

data "github_actions_secret" "aws_secret_access_key" {
  name        = "AWS_SECRET_ACCESS_KEY_LOCALSTACK"
  repository  = "my-repo"
}