# vpc-peering-accepter

This module accepts VPC Peering request.

## Usage

This module has three functions:

- Accepts VPC peering requests and creates routes that indicate VPC-peering.
- Accepts multiple VPC Peering requests without route propagation.
- Accepts multiple VPC Peering requests with route propagation.

## Accept peering request with route propagation

```hcl
module "peering-accepter" {
  source  = "../vpc-peering-requester"

    vpc_peer_id = dependency.vpc-requester.outputs.vpc_peering_id
    requester_vpc_cidr_block = dependency.vpc-requester.outputs.requester_vpc_cidr_block

    #Create route in database route table requester_vpc_cidr_block => vpc-peering-id
    accepter_database_route_table_ids = ["rtb-1","rtb-2"]

}
```

If you want to use this module with the vpc-peering-accepter module, set the `accepter_private_route_table_ids` variables. Because of the dependency cycle, the acceptor takes all of the variables from the requester.

`accepter_private_route_table_ids`

## Accept multiple peering requests without route propagation

```hcl
module "peering-accepter" {
  source  = "../vpc-peering-requester"

    vpc_peering_ids = dependency.vpc-requester.outputs.vpc_peering_id
    requester_vpc_cidr_block = dependency.vpc-requester.outputs.requester_vpc_cidr_block

    #Create route in database route table requester_vpc_cidr_block => vpc-peering-id
    accepter_database_route_table_ids = ["rtb-1","rtb-2"]

}
```

## Accept multiple peering requests with route propagation

```hcl
module "peering-accepter" {
  source  = "../vpc-peering-requester"

    vpc_peer_ids = dependency.vpc-requester.outputs.vpc_peer_ids

    #Create route in specified tables: requester_cidr => peer_id
    accepter_private_route_table_ids = ["rtb-1","rtb-2", "rtb-3"]
    requester_peer_info = [
        {
          requester_cidr = "192.168.240.0/21"
          peer_id = "pcx-03d3ebd458ebae90f"
        },
        {
          requester_cidr = "192.168.240.0/21"
          peer_id = "pcx-0016cf5631d7a80df"
        },
    ]
}
```

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
| [aws_route.accepter_private_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_public_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_table_multiple_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection_accepter.batch_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_accepter.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accepter_all_private_route_table_ids"></a> [accepter\_all\_private\_route\_table\_ids](#input\_accepter\_all\_private\_route\_table\_ids) | All private route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_private_route_table_ids"></a> [accepter\_private\_route\_table\_ids](#input\_accepter\_private\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_public_route_table_ids"></a> [accepter\_public\_route\_table\_ids](#input\_accepter\_public\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_requester_vpc_cidr_block"></a> [requester\_vpc\_cidr\_block](#input\_requester\_vpc\_cidr\_block) | The CIDR Block of the requester VPC | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the peering connection | `map(string)` | `{}` | no |
| <a name="input_vpc_peer_id"></a> [vpc\_peer\_id](#input\_vpc\_peer\_id) | VPC peering connection ID | `string` | `""` | no |
| <a name="input_vpc_peer_ids"></a> [vpc\_peer\_ids](#input\_vpc\_peer\_ids) | VPC peering connections IDs for batch operations | `list(string)` | `[]` | no |
| <a name="input_requester_peer_info"></a> [requester\_peer\_info](#input\_requester\_peer\_info) | VPC peering connections IDs and cidr blocks for batch operatipn | `list(object({ requester_cidr = string, peer_id = string}))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accepter_private_route_table_ids"></a> [accepter\_private\_route\_table\_ids](#output\_accepter\_private\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_accepter_public_route_table_ids"></a> [accepter\_public\_route\_table\_ids](#output\_accepter\_public\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_requester_vpc_cidr_block"></a> [requester\_vpc\_cidr\_block](#output\_requester\_vpc\_cidr\_block) | The CIDR Block of the requester VPC |
| <a name="output_vpc_peering_id"></a> [vpc\_peering\_id](#output\_vpc\_peering\_id) | ID of the vpc peering |
| <a name="output_routes_with_requester_peer_info"></a> [routes\_with\_requester\_peer\_info](#output\_routes\_with\_requester\_peer\_info) | Route table ids, requester cidr and peer id |
<!-- END_TF_DOCS -->