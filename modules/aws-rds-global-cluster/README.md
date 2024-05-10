# terraform-aws-rds-global-cluster

This module creates RDS Global Cluster.

## Usage

```hcl2
module "rds-global-cluster" {
  source  = "../terraform-aws-rds-global-cluster"

  global_cluster_identifier = "global-cluster-example"
  global_cluster_engine                    = "aurora-postgresql"
  global_cluster_engine_version            = "14.3"
  global_cluster_database_name             = "global_cluster_database"
  global_cluster_storage_encrypted         = true
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
| [aws_rds_global_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_cluster_database_name"></a> [global\_cluster\_database\_name](#input\_global\_cluster\_database\_name) | Global cluster database name | `string` | `""` | no |
| <a name="input_global_cluster_delete_protection"></a> [global\_cluster\_delete\_protection](#input\_global\_cluster\_delete\_protection) | Global cluster delete protection flag | `bool` | `true` | no |
| <a name="input_global_cluster_engine"></a> [global\_cluster\_engine](#input\_global\_cluster\_engine) | Global cluster db engine | `string` | `""` | no |
| <a name="input_global_cluster_engine_version"></a> [global\_cluster\_engine\_version](#input\_global\_cluster\_engine\_version) | Global cluster db engine version | `string` | `""` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | Global cluster identifier | `string` | `""` | no |
| <a name="input_global_cluster_storage_encrypted"></a> [global\_cluster\_storage\_encrypted](#input\_global\_cluster\_storage\_encrypted) | Global cluster storage encrypted flag | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Global cluster database name |
| <a name="output_engine"></a> [engine](#output\_engine) | Global cluster database engine |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | Global cluster database engine version |
| <a name="output_global_cluster_identifier"></a> [global\_cluster\_identifier](#output\_global\_cluster\_identifier) | Global cluster ID |
<!-- END_TF_DOCS -->
