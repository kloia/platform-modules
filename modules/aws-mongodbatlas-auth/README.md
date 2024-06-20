# terraform-aws-mongodbatlas-cluster
Terraform module which grants the configuration at the Atlas cluster to AWS

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
| [mongodbatlas_cloud_provider_access_authorization.auth_role](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_provider_access_authorization) | resource |
| [mongodbatlas_project.project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atlas_project_name"></a> [atlas\_project\_name](#input\_atlas\_project\_name) | MongoDB atlas project id | `string` | n/a | yes |
| <a name="input_atlas_role_id"></a> [atlas\_role\_id](#input\_atlas\_role\_id) | MongoDB atlas role id | `string` | n/a | yes |
| <a name="input_aws_iam_role_arn"></a> [aws\_iam\_role\_arn](#input\_aws\_iam\_role\_arn) | AWS IAM Role arn | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->