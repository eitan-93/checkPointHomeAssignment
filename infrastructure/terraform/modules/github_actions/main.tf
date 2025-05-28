# Trust relationship for GitHub OIDC
data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repository}:ref:refs/heads/main"]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "github_actions" {
  name = "github-actions-user"
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "aws_iam_policy" "github_actions" {
  name_prefix = "github-actions-policy-"  # avoids name conflict
  description = "Policy for GitHub Actions workflow"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

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

