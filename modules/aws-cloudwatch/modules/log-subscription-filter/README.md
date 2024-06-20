<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_subscription_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="role_arn"></a> [role\_arn](#role\_arn) | The ARN of an IAM role that grants Amazon CloudWatch Logs permissions to deliver ingested log events to the destination. If you use Lambda as a destination, you should skip this argument and use aws_lambda_permission resource for granting access from CloudWatch logs to the destination Lambda function. | `string` | `""` | no |
| <a name="filter_pattern"></a> [filter\_pattern](#filter\_pattern) | A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events. | `string` | `""` | yes |
| <a name="destination_arn"></a> [destination\_arn](#destination\_arn) | The ARN of the destination to deliver matching log events to. Kinesis stream or Lambda function ARN. | `string` | `true` | yes |
| <a name="log_group_names"></a> [log\_group\_names](#log\_group\_names) | The names of the log group to associate the subscription filter with | `list(string)` | `[]` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="subscription_filter_specs"></a> [subscription\_filter\_specs](#subscription\_filter\_specs) | Subscription Filter Specifications |
<!-- markdownlint-restore -->
