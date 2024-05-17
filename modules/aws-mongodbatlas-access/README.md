# terraform-aws-mongodbatlas-cluster
Terraform module which helps to enable access configuration for Atlas cluster on AWS

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 1.4.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 1.4.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_cloud_provider_access_setup.cloud_provider_access_role](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_provider_access_setup) | resource |
| [mongodbatlas_project.project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atlas_project_name"></a> [atlas\_project\_name](#input\_atlas\_project\_name) | MongoDB atlas project name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_atlas_assumed_role_external_id"></a> [atlas\_assumed\_role\_external\_id](#output\_atlas\_assumed\_role\_external\_id) | n/a |
| <a name="output_atlas_aws_account_arn"></a> [atlas\_aws\_account\_arn](#output\_atlas\_aws\_account\_arn) | n/a |
| <a name="output_atlas_role_id"></a> [atlas\_role\_id](#output\_atlas\_role\_id) | n/a |
<!-- END_TF_DOCS -->