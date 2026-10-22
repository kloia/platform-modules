# NAT gateways are read from AWS on every plan, so a gateway added later is covered on the next apply.
data "aws_nat_gateways" "this" {
  vpc_id = var.vpc_id

  filter {
    name   = "state"
    values = ["available"]
  }
  lifecycle {
    postcondition {
      condition     = length(self.ids) > 0
      error_message = "No available NAT gateway found in this VPC."
    }
  }
}

locals {
  # Sorted so the m0..mN query ids are stable between plans.
  gateways = sort(tolist(data.aws_nat_gateways.this.ids))
}

module "port_allocation" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  alarm_name        = "${var.name_prefix}-nat-${var.name}-port-allocation-errors"
  alarm_description = join(" ", compact(["A NAT gateway could not allocate a source port: outbound connections from the VPC are failing now because too many are open to the same destination. Look for clients opening many short-lived connections to one endpoint, or spread the load over more NAT gateways.", var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, g in local.gateways : "m${i}"])}])"
      label       = "Port allocation errors (worst NAT gateway)"
      return_data = true
    }],
    [for i, g in local.gateways : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/NATGateway"
        metric_name = "ErrorPortAllocation"
        stat        = "Sum"
        period      = var.period
        dimensions  = { NatGatewayId = g }
      }]
    }]
  )

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.port_allocation_errors_threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
