
<!-- markdownlint-disable -->
# terraform-aws-centralized-logging module 



Terraform module to provision a centralized logging service



## Introduction

This module will create:
- Elasticsearch(Opensearch) cluster with the specified node count in the provided subnets in a VPC
- Elasticsearch domain policy that accepts a list of IAM role ARNs from which to permit management traffic to the cluster
- Security Group to control access to the Elasticsearch domain (inputs to the Security Group are other Security Groups or CIDRs blocks to be allowed to connect to the cluster)
- DNS hostname record for Elasticsearch cluster (if DNS Zone ID is provided)
- DNS hostname record for Kibana (if DNS Zone ID is provided)
- Kinesis stream for streaming
- Kinesis delivery stream for sending logs to Elasticsearch
- Cloudwatch log group for failure logs of delivery stream
- S3 bucket for backup of delivery stream
- IAM role and policy for delivery stream to put logs to Elasticsearch, Cloudwatch etc.
- 

__NOTE:__ To enable [zone awareness](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains.html#es-managedomains-zoneawareness) to deploy Elasticsearch nodes into two different Availability Zones, you need to set `zone_awareness_enabled` to `true` and provide two different subnets in `subnet_ids`.
If you enable zone awareness for your domain, Amazon ES places an endpoint into two subnets.
The subnets must be in different Availability Zones in the same region.
If you don't enable zone awareness, Amazon ES places an endpoint into only one subnet. You also need to set `availability_zone_count` to `1`.



## Usage




```hcl
module "elasticsearch" {

  domain_name             = "es"
  security_groups         = ["sg-XXXXXXXXX", "sg-YYYYYYYY"]
  vpc_id                  = "vpc-XXXXXXXXX"
  subnet_ids              = ["subnet-XXXXXXXXX", "subnet-YYYYYYYY"]
  zone_awareness_enabled  = "true"
  elasticsearch_version   = "6.5"
  instance_type           = "t2.small.elasticsearch"
  instance_count          = 4
  ebs_volume_size         = 10
  iam_role_arns           = ["arn:aws:iam::XXXXXXXXX:role/ops", "arn:aws:iam::XXXXXXXXX:role/dev"]
  iam_actions             = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost"]
  encrypt_at_rest_enabled = true
  kibana_subdomain_name   = "kibana-es"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  domain_endpoint_options_enforce_https = false

  # Kinesis stream

  kinesis_stream_name = "kinesis stream"
  # kinesis_shard_count = 1 # needed to be specified if the stream mode is PROVISIONED
  kinesis_stream_retention_period = 24
  kinesis_stream_mode = "ON_DEMAND"


  # Kinesis Firehose
  firehose_role_name = "firehose-role"
  firehose_bucket_name = "firehose-bucket"
  firehose_policy_name = "firehose-policy"
  firehose_name = "logging-delivery-stream"
  firehose_es_index_name = "logging"
  firehose_index_rotation_period = "OneWeek"
  firehose_cw_log_group_name = "/aws/kinesisfirehose/firehose-lg"
  firehose_cw_log_stream_name = "DestinationDelivery"
  firehose_cw_log_group_retention_in_days = 30
}
```



<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.35.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.35.0 |


## Resources

| Name | Type |
|------|------|
| [aws_elasticsearch_domain.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [aws_elasticsearch_domain_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain_policy) | resource |
| [aws_iam_role.elasticsearch_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_service_linked_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.firehose-elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.firehose_backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_kinesis_stream.stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_kinesis_firehose_delivery_stream.firehose_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_cloudwatch_log_group.firehose_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.firehose_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_options"></a> [advanced\_options](#input\_advanced\_options) | Key-value string pairs to specify advanced configuration options | `map(string)` | `{}` | no |
| <a name="input_advanced_security_options_enabled"></a> [advanced\_security\_options\_enabled](#input\_advanced\_security\_options\_enabled) | AWS Elasticsearch Kibana enchanced security plugin enabling (forces new resource) | `bool` | `false` | no |
| <a name="input_advanced_security_options_internal_user_database_enabled"></a> [advanced\_security\_options\_internal\_user\_database\_enabled](#input\_advanced\_security\_options\_internal\_user\_database\_enabled) | Whether to enable or not internal Kibana user database for ELK OpenDistro security plugin | `bool` | `false` | no |
| <a name="input_advanced_security_options_master_user_arn"></a> [advanced\_security\_options\_master\_user\_arn](#input\_advanced\_security\_options\_master\_user\_arn) | ARN of IAM user who is to be mapped to be Kibana master user (applicable if advanced\_security\_options\_internal\_user\_database\_enabled set to false) | `string` | `""` | no |
| <a name="input_advanced_security_options_master_user_name"></a> [advanced\_security\_options\_master\_user\_name](#input\_advanced\_security\_options\_master\_user\_name) | Master user username (applicable if advanced\_security\_options\_internal\_user\_database\_enabled set to true) | `string` | `""` | no |
| <a name="input_advanced_security_options_master_user_password"></a> [advanced\_security\_options\_master\_user\_password](#input\_advanced\_security\_options\_master\_user\_password) | Master user password (applicable if advanced\_security\_options\_internal\_user\_database\_enabled set to true) | `string` | `""` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the cluster | `list(string)` | `[]` | no |
| <a name="input_automated_snapshot_start_hour"></a> [automated\_snapshot\_start\_hour](#input\_automated\_snapshot\_start\_hour) | Hour at which automated snapshots are taken, in UTC | `number` | `0` | no |
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count) | Number of Availability Zones for the domain to use. | `number` | `2` | no |
| <a name="input_aws_ec2_service_name"></a> [aws\_ec2\_service\_name](#input\_aws\_ec2\_service\_name) | AWS EC2 Service Name | `list(string)` | <pre>[<br>  "ec2.amazonaws.com"<br>]</pre> | no |
| <a name="input_cognito_authentication_enabled"></a> [cognito\_authentication\_enabled](#input\_cognito\_authentication\_enabled) | Whether to enable Amazon Cognito authentication with Kibana | `bool` | `false` | no |
| <a name="input_cognito_iam_role_arn"></a> [cognito\_iam\_role\_arn](#input\_cognito\_iam\_role\_arn) | ARN of the IAM role that has the AmazonESCognitoAccess policy attached | `string` | `""` | no |
| <a name="input_cognito_identity_pool_id"></a> [cognito\_identity\_pool\_id](#input\_cognito\_identity\_pool\_id) | The ID of the Cognito Identity Pool to use | `string` | `""` | no |
| <a name="input_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#input\_cognito\_user\_pool\_id) | The ID of the Cognito User Pool to use | `string` | `""` | no |
| <a name="input_create_iam_service_linked_role"></a> [create\_iam\_service\_linked\_role](#input\_create\_iam\_service\_linked\_role) | Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info | `bool` | `true` | no |
| <a name="input_custom_endpoint"></a> [custom\_endpoint](#input\_custom\_endpoint) | Fully qualified domain for custom endpoint. | `string` | `""` | no |
| <a name="input_custom_endpoint_certificate_arn"></a> [custom\_endpoint\_certificate\_arn](#input\_custom\_endpoint\_certificate\_arn) | ACM certificate ARN for custom endpoint. | `string` | `""` | no |
| <a name="input_custom_endpoint_enabled"></a> [custom\_endpoint\_enabled](#input\_custom\_endpoint\_enabled) | Whether to enable custom endpoint for the Elasticsearch domain. | `bool` | `false` | no |
| <a name="input_dedicated_master_count"></a> [dedicated\_master\_count](#input\_dedicated\_master\_count) | Number of dedicated master nodes in the cluster | `number` | `0` | no |
| <a name="input_dedicated_master_enabled"></a> [dedicated\_master\_enabled](#input\_dedicated\_master\_enabled) | Indicates whether dedicated master nodes are enabled for the cluster | `bool` | `false` | no |
| <a name="input_dedicated_master_type"></a> [dedicated\_master\_type](#input\_dedicated\_master\_type) | Instance type of the dedicated master nodes in the cluster | `string` | `"t2.small.elasticsearch"` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | Route53 DNS Zone ID to add hostname records for Elasticsearch domain and Kibana | `string` | `""` | no |
| <a name="input_domain_endpoint_options_enforce_https"></a> [domain\_endpoint\_options\_enforce\_https](#input\_domain\_endpoint\_options\_enforce\_https) | Whether or not to require HTTPS | `bool` | `true` | no |
| <a name="input_domain_endpoint_options_tls_security_policy"></a> [domain\_endpoint\_options\_tls\_security\_policy](#input\_domain\_endpoint\_options\_tls\_security\_policy) | The name of the TLS security policy that needs to be applied to the HTTPS endpoint | `string` | `"Policy-Min-TLS-1-0-2019-07"` | no |
| <a name="input_domain_hostname_enabled"></a> [domain\_hostname\_enabled](#input\_domain\_hostname\_enabled) | Explicit flag to enable creating a DNS hostname for ES. If `true`, then `var.dns_zone_id` is required. | `bool` | `false` | no |
| <a name="input_ebs_iops"></a> [ebs\_iops](#input\_ebs\_iops) | The baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the Provisioned IOPS EBS volume type | `number` | `0` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | EBS volumes for data storage in GB | `number` | `0` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | Storage type of EBS volumes | `string` | `"gp2"` | no |
| <a name="input_elasticsearch_subdomain_name"></a> [elasticsearch\_subdomain\_name](#input\_elasticsearch\_subdomain\_name) | The name of the subdomain for Elasticsearch in the DNS zone (\_e.g.\_ `elasticsearch`, `ui`, `ui-es`, `search-ui`) | `string` | `""` | no |
| <a name="input_elasticsearch_version"></a> [elasticsearch\_version](#input\_elasticsearch\_version) | Version of Elasticsearch to deploy (\_e.g.\_ `7.4`, `7.1`, `6.8`, `6.7`, `6.5`, `6.4`, `6.3`, `6.2`, `6.0`, `5.6`, `5.5`, `5.3`, `5.1`, `2.3`, `1.5` | `string` | `"7.4"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_encrypt_at_rest_enabled"></a> [encrypt\_at\_rest\_enabled](#input\_encrypt\_at\_rest\_enabled) | Whether to enable encryption at rest | `bool` | `true` | no |
| <a name="input_encrypt_at_rest_kms_key_id"></a> [encrypt\_at\_rest\_kms\_key\_id](#input\_encrypt\_at\_rest\_kms\_key\_id) | The KMS key ID to encrypt the Elasticsearch domain with. If not specified, then it defaults to using the AWS/Elasticsearch service KMS key | `string` | `""` | no |
| <a name="input_iam_actions"></a> [iam\_actions](#input\_iam\_actions) | List of actions to allow for the IAM roles, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost` | `list(string)` | `[]` | no |
| <a name="input_iam_authorizing_role_arns"></a> [iam\_authorizing\_role\_arns](#input\_iam\_authorizing\_role\_arns) | List of IAM role ARNs to permit to assume the Elasticsearch user role | `list(string)` | `[]` | no |
| <a name="input_iam_role_arns"></a> [iam\_role\_arns](#input\_iam\_role\_arns) | List of IAM role ARNs to permit access to the Elasticsearch domain | `list(string)` | `[]` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | The maximum session duration (in seconds) for the user role. Can have a value from 1 hour to 12 hours | `number` | `3600` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | The ARN of the permissions boundary policy which will be attached to the Elasticsearch user role | `string` | `null` | no |
| <a name="input_ingress_port_range_end"></a> [ingress\_port\_range\_end](#input\_ingress\_port\_range\_end) | End number for allowed port range. (e.g. `443`) | `number` | `65535` | no |
| <a name="input_ingress_port_range_start"></a> [ingress\_port\_range\_start](#input\_ingress\_port\_range\_start) | Start number for allowed port range. (e.g. `443`) | `number` | `0` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of data nodes in the cluster | `number` | `4` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Elasticsearch instance type for data nodes in the cluster | `string` | `"t2.small.elasticsearch"` | no |
| <a name="input_kibana_hostname_enabled"></a> [kibana\_hostname\_enabled](#input\_kibana\_hostname\_enabled) | Explicit flag to enable creating a DNS hostname for Kibana. If `true`, then `var.dns_zone_id` is required. | `bool` | `false` | no |
| <a name="input_kibana_subdomain_name"></a> [kibana\_subdomain\_name](#input\_kibana\_subdomain\_name) | The name of the subdomain for Kibana in the DNS zone (\_e.g.\_ `kibana`, `ui`, `ui-es`, `search-ui`, `kibana.elasticsearch`) | `string` | `""` | no |
| <a name="input_log_publishing_application_cloudwatch_log_group_arn"></a> [log\_publishing\_application\_cloudwatch\_log\_group\_arn](#input\_log\_publishing\_application\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group to which log for ES\_APPLICATION\_LOGS needs to be published | `string` | `""` | no |
| <a name="input_log_publishing_application_enabled"></a> [log\_publishing\_application\_enabled](#input\_log\_publishing\_application\_enabled) | Specifies whether log publishing option for ES\_APPLICATION\_LOGS is enabled or not | `bool` | `false` | no |
| <a name="input_log_publishing_audit_cloudwatch_log_group_arn"></a> [log\_publishing\_audit\_cloudwatch\_log\_group\_arn](#input\_log\_publishing\_audit\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group to which log for AUDIT\_LOGS needs to be published | `string` | `""` | no |
| <a name="input_log_publishing_audit_enabled"></a> [log\_publishing\_audit\_enabled](#input\_log\_publishing\_audit\_enabled) | Specifies whether log publishing option for AUDIT\_LOGS is enabled or not | `bool` | `false` | no |
| <a name="input_log_publishing_index_cloudwatch_log_group_arn"></a> [log\_publishing\_index\_cloudwatch\_log\_group\_arn](#input\_log\_publishing\_index\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group to which log for INDEX\_SLOW\_LOGS needs to be published | `string` | `""` | no |
| <a name="input_log_publishing_index_enabled"></a> [log\_publishing\_index\_enabled](#input\_log\_publishing\_index\_enabled) | Specifies whether log publishing option for INDEX\_SLOW\_LOGS is enabled or not | `bool` | `false` | no |
| <a name="input_log_publishing_search_cloudwatch_log_group_arn"></a> [log\_publishing\_search\_cloudwatch\_log\_group\_arn](#input\_log\_publishing\_search\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group to which log for SEARCH\_SLOW\_LOGS needs to be published | `string` | `""` | no |
| <a name="input_log_publishing_search_enabled"></a> [log\_publishing\_search\_enabled](#input\_log\_publishing\_search\_enabled) | Specifies whether log publishing option for SEARCH\_SLOW\_LOGS is enabled or not | `bool` | `false` | no |
| <a name="input_node_to_node_encryption_enabled"></a> [node\_to\_node\_encryption\_enabled](#input\_node\_to\_node\_encryption\_enabled) | Whether to enable node-to-node encryption | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs to be allowed to connect to the cluster | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | VPC Subnet IDs | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_vpc_enabled"></a> [vpc\_enabled](#input\_vpc\_enabled) | Set to false if ES should be deployed outside of VPC. | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `null` | no |
| <a name="input_warm_count"></a> [warm\_count](#input\_warm\_count) | Number of UltraWarm nodes | `number` | `2` | no |
| <a name="input_warm_enabled"></a> [warm\_enabled](#input\_warm\_enabled) | Whether AWS UltraWarm is enabled | `bool` | `false` | no |
| <a name="input_warm_type"></a> [warm\_type](#input\_warm\_type) | Type of UltraWarm nodes | `string` | `"ultrawarm1.medium.elasticsearch"` | no |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled) | Enable zone awareness for Elasticsearch cluster | `bool` | `true` | no |
| <a name="input_kinesis_stream_name"></a> [kinesis\_stream\_name](#input\_kinesis\_stream\_name) | Name of the Kinesis Stream | `string` | `""` | yes |
| <a name="input_kinesis_shard_count"></a> [kinesis\_shard\_count](#input\_kinesis\_shard\_count) | Shard count of the Kinesis Stream \needed if the stream mode is provisioned! | `number` | `1` | no |
| <a name="input_kinesis_stream_retention_period"></a> [kinesis\_stream\_retention\_period](#input\_kinesis\_stream\_retention\_period) | Kinesis stream retention period | `number` | `1` | yes |
| <a name="input_kinesis_stream_mode"></a> [kinesis\_stream\_mode](#input\_kinesis\_stream\_mode) | Kinesis stream mode ONDEMAND/PROVISIONED | `bool` | `true` | yes |
| <a name="input_firehose_role_name"></a> [firehose\_role\_name](#input\_firehose\_role\_name) | Firehose role name to for related services | `bool` | `true` | yes |
| <a name="input_firehose_bucket_name"></a> [firehose\_bucket\_name](#input\_firehose\_bucket\_name) | Firehose bucket name for operations that it does | `bool` | `true` | yes |
| <a name="input_firehose_policy_name"></a> [firehose\_policy\_name](#input\_firehose\_policy\_name) | Firehose policy name | `bool` | `true` | yes |
| <a name="input_firehose_name"></a> [firehose\_name](#input\_firehose\_name) | Firehose name | `bool` | `true` | yes |
| <a name="input_firehose_es_index_name"></a> [firehose\_es\_index\_name](#input\_firehose\_es\_index\_name) | Firehose es index name | `bool` | `true` | yes |
| <a name="input_firehose_index_rotation_period"></a> [firehose\_index\_rotation\_period](#input\_firehose\_index\_rotation\_period) | Firehose index rotation period | `bool` | `true` | yes |
| <a name="input_firehose_cw_log_group_name"></a> [firehose\_cw\_log\_group\_name](#input\_firehose\_cw\_log\_group\_name) | Firehose Cloudwatch log group name | `bool` | `true` | yes |
| <a name="input_firehose_cw_log_stream_name"></a> [firehose\_cw\_log\_stream\_name](#input\_firehose\_cw\_log\_stream\_name) | Firehose Cloudwatch log group name | `bool` | `true` | yes |
| <a name="input_firehose_cw_log_group_retention_in_days"></a> [firehose\_cw\_log\_group\_retention\_in\_days](#input\_firehose\_cw\_log\_group\_retention\_in\_days) | Retention time | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the Elasticsearch domain |
| <a name="output_domain_endpoint"></a> [domain\_endpoint](#output\_domain\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests |
| <a name="output_domain_hostname"></a> [domain\_hostname](#output\_domain\_hostname) | Elasticsearch domain hostname to submit index, search, and data upload requests |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Unique identifier for the Elasticsearch domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the Elasticsearch domain |
| <a name="output_elasticsearch_user_iam_role_arn"></a> [elasticsearch\_user\_iam\_role\_arn](#output\_elasticsearch\_user\_iam\_role\_arn) | The ARN of the IAM role to allow access to Elasticsearch cluster |
| <a name="output_elasticsearch_user_iam_role_name"></a> [elasticsearch\_user\_iam\_role\_name](#output\_elasticsearch\_user\_iam\_role\_name) | The name of the IAM role to allow access to Elasticsearch cluster |
| <a name="output_kibana_endpoint"></a> [kibana\_endpoint](#output\_kibana\_endpoint) | Domain-specific endpoint for Kibana without https scheme |
| <a name="output_kibana_hostname"></a> [kibana\_hostname](#output\_kibana\_hostname) | Kibana hostname |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group ID to control access to the Elasticsearch domain |
<!-- markdownlint-restore -->





## References

For additional context, refer to some of these links.

- [What is Amazon Elasticsearch Service](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/what-is-amazon-elasticsearch-service.html) - Complete description of Amazon Elasticsearch Service
- [Amazon Elasticsearch Service Access Control](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html) - Describes several ways of controlling access to Elasticsearch domains
- [VPC Support for Amazon Elasticsearch Service Domains](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-vpc.html) - Describes Elasticsearch Service VPC Support and VPC architectures with and without zone awareness
- [Creating and Configuring Amazon Elasticsearch Service Domains](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html) - Provides a complete description on how to create and configure Amazon Elasticsearch Service (Amazon ES) domains
- [Kibana and Logstash](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-kibana.html) - Describes some considerations for using Kibana and Logstash with Amazon Elasticsearch Service
- [Amazon Cognito Authentication for Kibana](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-cognito-auth.html) - Amazon Elasticsearch Service uses Amazon Cognito to offer user name and password protection for Kibana
- [Control Access to Amazon Elasticsearch Service Domain](https://aws.amazon.com/blogs/security/how-to-control-access-to-your-amazon-elasticsearch-service-domain/) - Describes how to Control Access to Amazon Elasticsearch Service Domain
- [elasticsearch_domain](https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html) - Terraform reference documentation for the `elasticsearch_domain` resource
- [elasticsearch_domain_policy](https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain_policy.html) - Terraform reference documentation for the `elasticsearch_domain_policy` resource
- [centralized_logging_architecture](https://docs.aws.amazon.com/solutions/latest/centralized-logging-on-aws/overview.html) - AWS reference documentation for the architecture