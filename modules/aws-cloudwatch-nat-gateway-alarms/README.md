# aws-cloudwatch-nat-gateway-alarms

Port-allocation and dropped-packet alarms for zonal NAT gateways, looked up by ID.

Two alarms per gateway, each firing when the metric reaches its threshold (default 1) in one period:

- **port allocation**: `ErrorPortAllocation`, Sum. AWS: a value above zero means too many concurrent connections
  are open through the gateway.
- **packets dropped**: `PacketsDropCount`, Sum. AWS suggests comparing it with total traffic (it points to a
  service problem above 0.01% of packets), so a low non-zero count can be noise on a busy gateway; raise
  `packets_drop_threshold` for it.

Gateways are keyed by a label of your choice, used in the alarm names, and given by `id`. Only zonal gateways are
covered: AWS lists a regional gateway's metrics under `NatGatewayId` together with `AvailabilityZone`. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Set the module-wide defaults, then override per resource; an omitted field uses the default:

```hcl
module "alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-nat-gateway-alarms/v0.1.0"

  name_prefix = "team-prod"

  gateways = {
    az-a = { id = "nat-0123456789abcdef0" }
    az-b = { id = "nat-0fedcba9876543210", packets_drop_threshold = 100 }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Missing data counts as not breaching. Names: `<name_prefix>-nat-<label>-<port-allocation|packets-dropped>`. Source: VPC user guide, "NAT gateway metrics and dimensions".
