resource "aws_ssm_parameter" "token" {
  name  = "token"
  type  = "SecureString"
  value = "my-token-value"
}