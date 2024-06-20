Custom module to configure health check and related AWS CloudWatch alarms.

## Usage

```hcl
module "route53_health_check" {
  source = "trussworks/route53-health-check/aws"
  version = "2.0.0"

  environment       = var.environment
  dns_name          = local.my_move_dns_name
  alarm_actions     = compact(local.r53_alarm_actions)
  health_check_path = "/health?database=false"
}
```

## Terraform Versions

Terraform 0.12. Pin module version to ~> 2.X. Submit pull-requests to master branch.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_route53_health_check.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_health_check.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | Actions to execute when this alarm transitions. | `list(string)` | n/a | yes |
| <a name="input_alarm_name_suffix"></a> [alarm\_name\_suffix](#input\_alarm\_name\_suffix) | Suffix for cloudwatch alarm name to ensure uniqueness. | `string` | `""` | no |
| <a name="input_disable"></a> [disable](#input\_disable) | Disable health checks | `bool` | `false` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | Fully-qualified domain name (FQDN) to create. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag (e.g. prod). | `string` | n/a | yes |
| <a name="input_failure_threshold"></a> [failure\_threshold](#input\_failure\_threshold) | Failure Threshold (must be less than or equal to 10) | `string` | `"3"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Resource Path to check | `string` | `""` | no |
| <a name="input_health_check_regions"></a> [health\_check\_regions](#input\_health\_check\_regions) | AWS Regions for health check | `list(string)` | <pre>[<br>  "us-east-1",<br>  "us-west-1",<br>  "us-west-2"<br>]</pre> | no |
| <a name="input_request_interval"></a> [request\_interval](#input\_request\_interval) | Request Interval (must be 10 or 30) | `string` | `"30"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
