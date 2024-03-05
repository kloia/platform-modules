output "atlas_assumed_role_external_id" {
    value = mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role.aws_config[0].atlas_assumed_role_external_id
}

output "atlas_aws_account_arn" {
    value = mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role.aws_config[0].atlas_aws_account_arn
}

output "atlas_role_id" {
    value = mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role.role_id
}

output "project_id"{
  description = "Mongoatlas project ID"
  value = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
}

