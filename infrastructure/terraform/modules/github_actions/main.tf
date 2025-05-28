
resource "github_actions_secret" "aws_access_key_id" {
  repository      = var.repository
  secret_name     = var.aws_access_key_id_secret_name
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository      = var.repository
  secret_name     = var.aws_secret_access_key_secret_name
  plaintext_value = var.aws_secret_access_key
}
