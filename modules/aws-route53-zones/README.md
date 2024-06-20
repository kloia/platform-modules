# Route53 Zones

This module creates Route53 zones.

## Usage

```hcl
module "zones" {
  source  = "../terraform-aws-route53-zones"
  version = "~> 0.1"

  zones = {
    "public.route53-zone.com" = {
      domain_name = "route53-zone.com"
      create_zone = true
      comment = "route53-zone.com (production)"
      tags = {
        env = "production"
      }
    }
    "private.route53-zone.com" = {
      domain_name = "route53-zone.com"
      create_zone = true
      comment = "route53-zone.com (production)"
      tags = {
        env = "production"
      }
      vpc = [
        {
          vpc_id = <vpc_id>
        },
        {
          vpc_id = <vpc_id>
        },
      ]
    }

  }
}
```

## Use module with existing zone

If you want to get output values of existing route 53 zone, dont set set `create_zone` variable or set `false`.

```hcl
module "zones" {
  source  = "../terraform-aws-route53-zones"
  version = "~> 2.0"

  zones = {
    "data.route53-zone.com" = {
      domain_name = "route53-zone.com"
      comment = "route53-zone.com (production)"
      tags = {
        env = "production"
      }
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.49 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create Route53 zone | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags added to all zones. Will take precedence over tags from the 'zones' variable | `map(any)` | `{}` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Map of Route53 zone parameters | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route53_zone_name"></a> [route53\_zone\_name](#output\_route53\_zone\_name) | Name of Route53 zone |
| <a name="output_route53_zone_name_servers"></a> [route53\_zone\_name\_servers](#output\_route53\_zone\_name\_servers) | Name servers of Route53 zone |
| <a name="output_route53_zone_zone_id"></a> [route53\_zone\_zone\_id](#output\_route53\_zone\_zone\_id) | Zone ID of Route53 zone |
<!-- END_TF_DOCS -->