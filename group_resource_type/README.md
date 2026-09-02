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
| [aws_shield_protection_group.resource_type_protection_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_type_protection_group"></a> [resource\_type\_protection\_group](#input\_resource\_type\_protection\_group) | all shield protection group values list as resource type | <pre>list(object({<br>    group_id      = string<br>    aggregation   = string<br>    members       = list(string)<br>    resource_type = string<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->