# vpc-peering-accepter

This module accepts VPC Peering request.

## Usage

This module has two functions:

- Accepts VPC peering requests and creates routes that indicate VPC-peering.
- Accepts multiple VPC Peering requests without route propagation

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

If you want to use this module with the vpc-peering-accepter module, set the `accepter_x_route_table_ids` variables. Because of the dependency cycle, the acceptor takes all of the variables from the requester.

`accepter_x_route_table_ids`
available `x` values:

- ecs
- eks
- private
- public
- cache
- database

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
| [aws_route.accepter_cache_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_database_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_ecs_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_eks_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_mq_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_private_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.accepter_public_route_table_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection_accepter.batch_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_accepter.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accepter_cache_route_table_ids"></a> [accepter\_cache\_route\_table\_ids](#input\_accepter\_cache\_route\_table\_ids) | The cache route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_database_route_table_ids"></a> [accepter\_database\_route\_table\_ids](#input\_accepter\_database\_route\_table\_ids) | The database route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_ecs_route_table_ids"></a> [accepter\_ecs\_route\_table\_ids](#input\_accepter\_ecs\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_eks_route_table_ids"></a> [accepter\_eks\_route\_table\_ids](#input\_accepter\_eks\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_mq-broker_route_table_ids"></a> [accepter\_mq-broker\_route\_table\_ids](#input\_accepter\_mq-broker\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_mq_route_table_ids"></a> [accepter\_mq\_route\_table\_ids](#input\_accepter\_mq\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_private_route_table_ids"></a> [accepter\_private\_route\_table\_ids](#input\_accepter\_private\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_accepter_public_route_table_ids"></a> [accepter\_public\_route\_table\_ids](#input\_accepter\_public\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables | `list(string)` | `[]` | no |
| <a name="input_requester_vpc_cidr_block"></a> [requester\_vpc\_cidr\_block](#input\_requester\_vpc\_cidr\_block) | The CIDR Block of the requester VPC | `string` | `""` | no |
| <a name="input_vpc_peer_id"></a> [vpc\_peer\_id](#input\_vpc\_peer\_id) | VPC peering connection ID | `string` | `""` | no |
| <a name="input_vpc_peer_ids"></a> [vpc\_peer\_ids](#input\_vpc\_peer\_ids) | VPC peering connections IDs for batch operations | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accepter_cache_route_table_ids"></a> [accepter\_cache\_route\_table\_ids](#output\_accepter\_cache\_route\_table\_ids) | The cache route table IDs of accepter VPC route tables |
| <a name="output_accepter_database_route_table_ids"></a> [accepter\_database\_route\_table\_ids](#output\_accepter\_database\_route\_table\_ids) | The database route table IDs of accepter VPC route tables |
| <a name="output_accepter_ecs_route_table_ids"></a> [accepter\_ecs\_route\_table\_ids](#output\_accepter\_ecs\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_accepter_eks_route_table_ids"></a> [accepter\_eks\_route\_table\_ids](#output\_accepter\_eks\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_accepter_mq_route_table_ids"></a> [accepter\_mq\_route\_table\_ids](#output\_accepter\_mq\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_accepter_private_route_table_ids"></a> [accepter\_private\_route\_table\_ids](#output\_accepter\_private\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_accepter_public_route_table_ids"></a> [accepter\_public\_route\_table\_ids](#output\_accepter\_public\_route\_table\_ids) | The eks route table IDs of accepter VPC route tables |
| <a name="output_requester_vpc_cidr_block"></a> [requester\_vpc\_cidr\_block](#output\_requester\_vpc\_cidr\_block) | The CIDR Block of the requester VPC |
| <a name="output_vpc_peering_id"></a> [vpc\_peering\_id](#output\_vpc\_peering\_id) | ID of the vpc peering |
<!-- END_TF_DOCS -->