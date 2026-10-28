
<!-- markdownlint-disable -->
# terraform-aws-ssm-parameter-store

Terraform module for providing read and write access to the AWS SSM Parameter Store.

---


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

Also, because of a bug in the Terraform registry ([hashicorp/terraform#21417](https://github.com/hashicorp/terraform/issues/21417)),
the registry shows many of our inputs as required when in fact they are optional.
The table below correctly indicates which inputs are required.


This example creates a new `String` parameter called `/cp/prod/app/database/master_password` with the value of `password1`.

```hcl
module "store_write" {
  source  = "kloia/ssm-parameter-store/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  parameter_write = [
    {
      name        = "/cp/prod/app/database/master_password"
      value       = "password1"
      type        = "String"
      overwrite   = "true"
      description = "Production database master password"
    }
  ]

  tags = {
    ManagedBy = "Terraform"
  }
}
```

This example reads a value from the parameter store with the name `/cp/prod/app/database/master_password`

```hcl
module "store_read" {
  source  = "kloia/ssm-parameter-store/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  parameter_read = ["/cp/prod/app/database/master_password"]
}
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.ignore_value_changes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_ignore_value_changes"></a> [ignore\_value\_changes](#input\_ignore\_value\_changes) | Whether to ignore future external changes in paramater values | `bool` | `false` | no |
| <a name="input_kms_arn"></a> [kms\_arn](#input\_kms\_arn) | The ARN of a KMS key used to encrypt and decrypt SecretString values | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_parameter_read"></a> [parameter\_read](#input\_parameter\_read) | List of parameters to read from SSM. These must already exist otherwise an error is returned. Can be used with `parameter_write` as long as the parameters are different. | `list(string)` | `[]` | no |
| <a name="input_parameter_write"></a> [parameter\_write](#input\_parameter\_write) | List of maps with the parameter values to write to SSM Parameter Store | `list(map(string))` | `[]` | no |
| <a name="input_parameter_write_defaults"></a> [parameter\_write\_defaults](#input\_parameter\_write\_defaults) | Parameter write default settings | `map(any)` | <pre>{<br>  "allowed_pattern": null,<br>  "data_type": "text",<br>  "description": null,<br>  "overwrite": "false",<br>  "tier": "Standard",<br>  "type": "SecureString"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="cross_account_read"></a> [tags](#cross\_account\_read) | Whether to create read parameter store data from cross account.  | `bool` | `false` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn_map"></a> [arn\_map](#output\_arn\_map) | A map of the names and ARNs created |
| <a name="output_map"></a> [map](#output\_map) | A map of the names and values created |
| <a name="output_names"></a> [names](#output\_names) | A list of all of the parameter names |
| <a name="output_values"></a> [values](#output\_values) | A list of all of the parameter values |

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-ssm-parameter-store/issues) to report any bugs or file feature requests.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.ignore_value_changes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Create resources if enabled true | `bool` | `true` | no |
| <a name="input_ignore_value_changes"></a> [ignore\_value\_changes](#input\_ignore\_value\_changes) | Whether to ignore future external changes in paramater values | `bool` | `false` | no |
| <a name="input_kms_arn"></a> [kms\_arn](#input\_kms\_arn) | The ARN of a KMS key used to encrypt and decrypt SecretString values | `string` | `""` | no |
| <a name="input_parameter_read"></a> [parameter\_read](#input\_parameter\_read) | List of parameters to read from SSM. These must already exist otherwise an error is returned. Can be used with `parameter_write` as long as the parameters are different. | `list(string)` | `[]` | no |
| <a name="input_parameter_write"></a> [parameter\_write](#input\_parameter\_write) | List of maps with the parameter values to write to SSM Parameter Store | `list(map(string))` | `[]` | no |
| <a name="input_parameter_write_defaults"></a> [parameter\_write\_defaults](#input\_parameter\_write\_defaults) | Parameter write default settings | `map(any)` | <pre>{<br>  "allowed_pattern": null,<br>  "data_type": "text",<br>  "description": null,<br>  "overwrite": "false",<br>  "tier": "Standard",<br>  "type": "SecureString"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn_map"></a> [arn\_map](#output\_arn\_map) | A map of the names and ARNs created |
| <a name="output_map"></a> [map](#output\_map) | A map of the names and values created |
| <a name="output_names"></a> [names](#output\_names) | A list of all of the parameter names |
| <a name="output_values"></a> [values](#output\_values) | A list of all of the parameter values |
<!-- END_TF_DOCS -->