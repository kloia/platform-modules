output "database_user_credentials" {
  description = "Map of database users and passwords"
  value = merge(
    { for key, value in var.database_users : lookup(value, "username") => lookup(value, "password") if lookup(value, "password", null) != null },
  { for key, value in var.database_users : lookup(value, "username") => random_password.password[key].result if(lookup(value, "password", null) == null && lookup(value, "aws_iam_type", null) == null) })
  sensitive = true
}