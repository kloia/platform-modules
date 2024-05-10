# Route53 Records

This module creates DNS records in Route53 zone.

## Usage

```hcl
module "records" {
  source  = "../terraform-aws-route53-records"
  version = "~> 2.0"

  zone_name = "<zone_name>"
  private_zone = <bool> #Set true if zone is private

  records = [
    {
      name    = "apigateway1"
      type    = "A"
      alias   = {
        name    = "d-10qxlbvagl.execute-api.eu-west-1.amazonaws.com"
        zone_id = "ZLY8HYME6SFAD"
      }
    },
    {
      name    = ""
      type    = "A"
      ttl     = 3600
      records = [
        "10.10.10.10",
      ]
    },
  ]

}
```

## Terragrunt issue

Due to a bug in Terragrunt (https://github.com/gruntwork-io/terragrunt/issues/1211), users should specify records using `records_jsonencoded` argument as jsonencode()'d string, like this:

```hcl
records_jsonencoded = jsonencode([
  {
    name = "tg-list1"
    type = "A"
    ttl  = 3600
    records = [
      "10.10.10.10",
    ]
  },
  {
    name = "tg-list2"
    type = "A"
    ttl  = 3600
    records = [
      "20.10.10.10",
      "30.10.10.10",
    ]
  }
])
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create DNS records | `bool` | `true` | no |
| <a name="input_private_zone"></a> [private\_zone](#input\_private\_zone) | Whether Route53 zone is private or public | `bool` | `false` | no |
| <a name="input_records"></a> [records](#input\_records) | List of objects of DNS records | `any` | `[]` | no |
| <a name="input_records_jsonencoded"></a> [records\_jsonencoded](#input\_records\_jsonencoded) | List of map of DNS records (stored as jsonencoded string, for terragrunt) | `string` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | ID of DNS zone | `string` | `null` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of DNS zone | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route53_record_fqdn"></a> [route53\_record\_fqdn](#output\_route53\_record\_fqdn) | FQDN built using the zone domain and name |
| <a name="output_route53_record_name"></a> [route53\_record\_name](#output\_route53\_record\_name) | The name of the record |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
