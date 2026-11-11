# aws-cloudwatch-transit-gateway-alarms

Packet-drop alarms for transit gateways, looked up by ID.

Per gateway, each alarm fires when the metric reaches its threshold (default 1) in one period:

- **blackhole**: `PacketDropCountBlackhole`, Sum. Packets dropped because they matched a `blackhole` route.
- **no route** (off by default, `enable_no_route_alarm`): `PacketDropCountNoRoute`, Sum. Packets that matched no
  route. Left off by default because stray traffic can legitimately match no route; enable it and set
  `no_route_threshold` from the gateway's own baseline.

AWS publishes both metrics on the `TransitGateway` dimension and reports them continuously, so a quiet gateway
shows 0. The module alarms at gateway level, not per attachment. Built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

Set the module-wide defaults, then override per resource; an omitted field uses the default:

```hcl
module "alarms" {
  # A release tag holds only this module at its root, so there is no `//modules/...` subdirectory.
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-cloudwatch-transit-gateway-alarms/v0.1.0"

  name_prefix = "team-prod"

  gateways = {
    hub    = { id = "tgw-0123456789abcdef0" }
    spoke  = { id = "tgw-0fedcba9876543210", blackhole_threshold = 10 }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Missing data counts as not breaching. Names: `<name_prefix>-tgw-<label>-<blackhole|no-route>`. Source: VPC Transit Gateways guide, "CloudWatch metrics in AWS Transit Gateway".

## Opsgenie priority

`priority` (`P1` to `P5`, default none) is written at the start of every alarm description as `[P2]`. An Opsgenie
CloudWatch integration with a rule that matches `"AlarmDescription":"[P2]` sets the alert priority from it;
without such a rule the prefix does nothing. With `priority` unset the descriptions are unchanged.
