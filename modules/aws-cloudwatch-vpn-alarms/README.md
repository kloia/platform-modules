# aws-cloudwatch-vpn-alarms

Alarms for one AWS Site-to-Site VPN connection, built on
[terraform-aws-modules/cloudwatch](https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/metric-alarm) `metric-alarm` 5.7.3.

| Alarm | Default |
|---|---|
| `tunnel-down` | at least one tunnel not up for 15 minutes (3 of 3 five-minute periods) |

With only the `VpnId` dimension, `TunnelState` is 1 when every tunnel is up and between 0 and 1 when at least
one is not ([VPN metrics](https://docs.aws.amazon.com/vpn/latest/s2svpn/monitoring-cloudwatch-vpn.html)),
so one alarm covers both tunnels without knowing their outside IPs. It fires when redundancy is lost, before
the second tunnel fails. Missing data counts as breaching.

## Usage

```hcl
module "vpn_alarms" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-cloudwatch-vpn-alarms?ref=module/aws-cloudwatch-vpn-alarms/v0.1.0"

  name_prefix       = "team-prod"
  name              = "datacenter"
  vpn_connection_id = "vpn-0123456789abcdef0"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

Alarm names: `<name_prefix>-vpn-<name>-<alarm>`.
