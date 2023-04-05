data "mongodbatlas_project" "project" {
  name = var.atlas_project_name
  
}

resource "mongodbatlas_cloud_provider_access_setup" "cloud_provider_access_role" {
   project_id = data.mongodbatlas_project.project.id
   provider_name = "AWS"
}