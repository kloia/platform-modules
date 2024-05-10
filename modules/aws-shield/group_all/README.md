<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.22 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.22 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_shield_protection_group.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aggregation"></a> [aggregation](#input\_aggregation) | Defines how AWS Shield combines resource data for the group in order to detect, mitigate, and report events. | `string` | `"SUM"` | no |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | The name of the protection group. | `string` | `"aws_shield_all"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->