resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  type        = "String"
  value       = "root"
  description = "db root username"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/db/password"
  type        = "SecureString"
  value       = "uninitialized"
  description = "db password"

  lifecycle {
    ignore_changes = [value]
  }
}
