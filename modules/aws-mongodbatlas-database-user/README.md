# terraform-aws-mongodbatlas-database-user
Terraform module which creates a Mongodb Atlas Database User



## Terraform versions

Terraform versions >=0.13.1 are supported

## Usage

```hcl
module "atlas_database_user" {
  source = "./terraform-aws-mongodbatlas-database-user"

  cluster_name = <cluster_name>
  project_id = <mongoatlas_project_id>
  database_users = {
    test-user-aws-iam = {
      username = <IAM_ROLE_ARN>
      auth_database_name = "$external"
      aws_iam_type = "ROLE"
      role_name = "readWriteAnyDatabase"
      database_name = "admin"
    },
    test-user-auto-generate-credentials = {
      username = "test_auto_generate_password"
      auth_database_name = "admin"
      role_name = "readWriteAnyDatabase"
      database_name = "admin"
    },
  }
}

```
## Prerequisites
* [MongoDB Cloud account](https://www.mongodb.com/cloud)
* [MongoDB Atlas Organization](https://cloud.mongodb.com/v2#/preferences/organizations/create)
* [MongoDB Atlas API key](https://www.terraform.io/docs/providers/mongodbatlas/index.html)

#### Manual tasks:

* Configure the API key before applying the module
* Get your MongoDB Atlas Organization ID from the UI

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_database_user.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Mongoatlas cluster name | `any` | n/a | yes |
| <a name="input_database_users"></a> [database\_users](#input\_database\_users) | n/a | `map(any)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Mongoatlas project ID | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_user_credentials"></a> [database\_user\_credentials](#output\_database\_user\_credentials) | Map of database users and passwords |
<!-- END_TF_DOCS -->