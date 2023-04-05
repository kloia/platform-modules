resource "random_password" "password" {
  for_each = {for key,value in var.database_users: key => value if lookup(value, "aws_iam_type", null) == null }
  length  = 14
  special = false
  upper   = false
}

resource "mongodbatlas_database_user" "this" {
  for_each           = var.database_users
  username           = lookup(each.value, "username")
  password           = lookup(each.value, "aws_iam_type", null) == null ? random_password.password[each.key].result : null
  project_id         = var.project_id
  auth_database_name = lookup(each.value, "auth_database_name")
  aws_iam_type       = lookup(each.value, "aws_iam_type", null)

  roles {
    role_name     = lookup(each.value, "role_name")
    database_name = lookup(each.value, "database_name")
  }


  scopes {
    name = var.cluster_name
    type = "CLUSTER"
  }

}
