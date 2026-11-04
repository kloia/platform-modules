# Runbook: NAT gateway alarms

Alarms from `aws-cloudwatch-nat-gateway-alarms`, per gateway. Names: `<name_prefix>-nat-<label>-port-allocation` and `-packets-dropped`. Conditions: `ErrorPortAllocation` or `PacketsDropCount` at or above the threshold in a period. The alarm description states the values.

> **Diagnose read-only first.** Replacing a NAT gateway changes the public IP that outbound traffic uses, which third parties may have allow-listed. Agree changes with the network owner.

```bash
P=<your-aws-profile>
R=<region>
NAT=<nat-gateway-id>
```

## Port allocation errors

**Meaning.** The gateway could not allocate a source port for a new connection. One NAT gateway supports about 55,000 simultaneous connections to a single destination (IP, port, protocol); beyond that new connections to it fail.

**Diagnose** (read-only):

```bash
aws ec2 describe-nat-gateways --profile $P --region $R --nat-gateway-ids $NAT \
  --query 'NatGateways[0].[State,SubnetId,NatGatewayAddresses[].PublicIp]' --output text
aws cloudwatch get-metric-statistics --profile $P --region $R --namespace AWS/NATGateway \
  --metric-name ActiveConnectionCount --dimensions Name=NatGatewayId,Value=$NAT \
  --start-time "$(date -u -v-3H +%Y-%m-%dT%H:%M:%SZ)" --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 300 --statistics Maximum --output table
```

(On Linux replace `date -u -v-3H` with `date -u -d '3 hours ago'`.) VPC Flow Logs for the NAT's network interface show which source and destination pairs hold the connections.

**Causes.**

1. One workload opens many connections to one destination without reusing them: the owner enables connection reuse or a pool.
2. A retry storm against an unreachable destination: fix the destination.
3. Genuine growth: spread the traffic over more gateways (one per zone) or add a secondary IP to the gateway.

## Packets dropped

**Meaning.** The gateway dropped packets, typically because of a connection tracking limit, a port-allocation failure or a problem inside the gateway. `PacketsDropCount` counts drops in either direction.

**Diagnose** (read-only): compare with `ErrorPortAllocation`, `BytesOutToDestination` and `PacketsOutToDestination` for the window, and check the AWS Health dashboard for the zone.

**Causes.**

1. Together with port-allocation errors: see above.
2. Alone and short: a transient AWS event; check AWS Health.
3. Alone and persistent: open an AWS Support case with the gateway id and the time window.

## Silencing

The alarm returns to OK by itself. Do not disable it; change the gateway's threshold through a pull request.
