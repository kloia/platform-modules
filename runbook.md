# Runbook: Transit gateway alarms

Alarms from `aws-cloudwatch-transit-gateway-alarms`, per transit gateway. Names: `<name_prefix>-tgw-<label>-blackhole` and `-no-route`. Conditions: `PacketDropCountBlackhole` or `PacketDropCountNoRoute` at or above the threshold in a period. The alarm description states the values.

> **Diagnose read-only first.** Route table changes on a transit gateway affect every attached network at once. Agree them with the network owner.

```bash
P=<your-aws-profile>
R=<region>
TGW=<transit-gateway-id>
```

## Blackhole drops

**Meaning.** Packets matched a route that is marked blackhole and were dropped. A route becomes blackhole when its attachment is deleted, or when it is added as blackhole on purpose. A drop means something still sends traffic to a destination that is no longer reachable.

**Diagnose** (read-only). List blackhole routes in every route table:

```bash
for rt in $(aws ec2 describe-transit-gateway-route-tables --profile $P --region $R \
  --filters Name=transit-gateway-id,Values=$TGW \
  --query 'TransitGatewayRouteTables[].TransitGatewayRouteTableId' --output text); do
  echo "== $rt"
  aws ec2 search-transit-gateway-routes --profile $P --region $R --transit-gateway-route-table-id $rt \
    --filters Name=state,Values=blackhole \
    --query 'Routes[].[DestinationCidrBlock,Type,State]' --output text
done
```

Then find the source: Transit Gateway Flow Logs, if enabled, or the attachment's `BytesIn` metric, show which attachment sends the dropped traffic.

**Causes.**

1. An attachment was deleted or its VPC recreated: the route stays as blackhole. Recreate the attachment or remove the route and the sender's route to it.
2. A deliberate blackhole route and something still sends to it: fix the sender.

## No-route drops

**Meaning.** Packets matched no route in the route table of the attachment they came from, so the destination range is not propagated or not added.

**Diagnose** (read-only): the same `search-transit-gateway-routes` call without the state filter, for the route table associated with the sending attachment; check that the destination's attachment propagates into it.

**Causes.**

1. A new network was attached but not propagated into the sender's route table.
2. The sender uses an address range that was never meant to be reachable: fix the sender.

> **State-modifying, only with the network owner's agreement:** `aws ec2 create-transit-gateway-route`, `delete-transit-gateway-route`, enabling propagation.

## Silencing

The alarm returns to OK by itself. Do not disable it; change the gateway's threshold through a pull request.
