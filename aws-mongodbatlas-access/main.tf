# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ATLAS PROJECT THAT THE CLUSTER WILL RUN INSIDE
# ---------------------------------------------------------------------------------------------------------------------

data "mongodbatlas_project" "project" {
  count  = var.create_mongodbatlas_project ? 0 : 1
  name = var.project_name
}

resource "mongodbatlas_project" "project" {
  count  = var.create_mongodbatlas_project ? 1 : 0
  name   = var.project_name
  org_id = var.org_id

  #Associate teams and privileges if passed, if not - run with an empty object
  dynamic "teams" {
    for_each = var.teams

    content {
      team_id    = mongodbatlas_team.team[teams.key].team_id
      role_names = [teams.value.role]
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE TEAMS FROM **EXISTING USERS**
# ---------------------------------------------------------------------------------------------------------------------

resource "mongodbatlas_team" "team" {
  for_each = var.teams

  org_id    = var.org_id
  name      = each.key
  usernames = each.value.users
}

resource "mongodbatlas_cloud_provider_access_setup" "cloud_provider_access_role" {
   project_id = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
   provider_name = "AWS"
}