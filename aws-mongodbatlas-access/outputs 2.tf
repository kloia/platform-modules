output "atlas_assumed_role_external_id" {
    value = mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role.aws.atlas_assumed_role_external_id
}

output "atlas_aws_account_arn" {
    value = mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role.aws.atlas_aws_account_arn
}

output "atlas_role_id" {
    value = mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role.role_id
}