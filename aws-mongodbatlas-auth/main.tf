data "mongodbatlas_project" "project" {
  name = var.project_name
  
}

resource "mongodbatlas_cloud_provider_access_authorization" "auth_role" {
   project_id =  data.mongodbatlas_project.project.id
   role_id    =  var.atlas_role_id

   aws {
      iam_assumed_role_arn = aws_iam_role.role.arn
   }
}