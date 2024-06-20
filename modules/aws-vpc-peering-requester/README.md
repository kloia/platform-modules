# vpc-peering-requester

This module creates VPC Peering request.

## Usage

This module has two functions: it creates VPC peering requests and it creates routes which indicate VPC-peering.

```hcl
module "peering-requester" {
  source  = "../vpc-peering-requester"

    peer_owner_account_id = "<vpc-peer.vpc_owner_id>"
    accepter_vpc_id = "<vpc-accepter.vpc_id>"
    accepter_vpc_cidr_block = "<vpc-accepter.vpc_cidr_block>"

    requester_vpc_cidr_block = "<vpc-peer.vpc_cidr_block>"
    requester_vpc_id = "<dependency.vpc-peer.vpc_id>"

    #Create route in private route table accepter_vpc_cidr_block => vpc-peering-id
    requester_private_route_table_ids = ["rtb-1","rtb-2"]

    peer_region = "<accepter_region>
}
```

If you want to use this module with the vpc-peering-accepter module, set the `accepter_private_route_table_ids` variables which you can have them via an explicit dependency from peering requester module outputs. Because of the dependency cycle, the acceptor takes all of the variables from the requester.

`accepter_private_route_table_ids`
`requester_private_route_table_ids`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.requester_private_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.requester_public_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accepter_private_route_table_ids"></a> [accepter\_private\_route\_table\_ids](#input\_accepter\_private\_route\_table\_ids) | Private route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_public_route_table_ids"></a> [accepter\_public\_route\_table\_ids](#input\_accepter\_public\_route\_table\_ids) | Public route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_vpc_cidr_block"></a> [accepter\_vpc\_cidr\_block](#input\_accepter\_vpc\_cidr\_block) | The CIDR Block of the accepter VPC | `string` | `""` | no |
| <a name="input_accepter_vpc_id"></a> [accepter\_vpc\_id](#input\_accepter\_vpc\_id) | The ID of the VPC with which you are creating the VPC Peering Connection | `string` | `""` | no |
| <a name="input_peer_owner_account_id"></a> [peer\_owner\_account\_id](#input\_peer\_owner\_account\_id) | The account ID of the peer owner | `string` | `""` | no |
| <a name="input_peer_region"></a> [peer\_region](#input\_peer\_region) | The region of the accepter side | `string` | `""` | no |
| <a name="input_requester_private_route_table_ids"></a> [requester\_private\_route\_table\_ids](#input\_requester\_private\_route\_table\_ids) | Private route table IDs of requester VPC route tables | `list(string)` | `[]` | no |
| <a name="input_requester_public_route_table_ids"></a> [requester\_public\_route\_table\_ids](#input\_requester\_public\_route\_table\_ids) | Public route table IDs of requester VPC route tables | `list(string)` | `[]` | no |
| <a name="input_requester_vpc_cidr_block"></a> [requester\_vpc\_cidr\_block](#input\_requester\_vpc\_cidr\_block) | The CIDR Block of the requester VPC | `string` | `""` | no |
| <a name="input_requester_vpc_id"></a> [requester\_vpc\_id](#input\_requester\_vpc\_id) | The ID of the requester VPC | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accepter_private_route_table_ids"></a> [accepter\_private\_route\_table\_ids](#output\_accepter\_private\_route\_table\_ids) | Private route table IDs of the accepter vpc |
| <a name="output_accepter_public_route_table_ids"></a> [accepter\_public\_route\_table\_ids](#output\_accepter\_public\_route\_table\_ids) | Public route table IDs of the accepter vpc |
| <a name="output_accepter_vpc_id"></a> [accepter\_vpc\_id](#output\_accepter\_vpc\_id) | ID of the accepter vpc |
| <a name="output_requester_vpc_cidr_block"></a> [requester\_vpc\_cidr\_block](#output\_requester\_vpc\_cidr\_block) | VPC CIDR block of the requester vpc |
| <a name="output_requester_vpc_id"></a> [requester\_vpc\_id](#output\_requester\_vpc\_id) | ID of the requester vpc |
| <a name="output_vpc_peering_id"></a> [vpc\_peering\_id](#output\_vpc\_peering\_id) | ID of the vpc peering |
<!-- END_TF_DOCS -->