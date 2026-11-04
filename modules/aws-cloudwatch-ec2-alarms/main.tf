# Instances are found by Name tag on every plan, so a replaced instance is covered on the next apply.
data "aws_instances" "this" {
  instance_state_names = ["running"]

  filter {
    name   = "tag:Name"
    values = var.instance_names
  }
  lifecycle {
    postcondition {
      condition     = length(self.ids) > 0
      error_message = "No running instance has one of the Name tags in instance_names."
    }
    postcondition {
      condition     = length(self.ids) <= 10
      error_message = "A metric math alarm can include at most 10 metrics; more than 10 instances matched. Split them over several units."
    }
  }
}

locals {
  # Sorted so the m0..mN query ids are stable between plans.
  instances = sort(data.aws_instances.this.ids)
}

module "status_check" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "5.7.3"

  alarm_name        = "${var.name_prefix}-ec2-${var.name}-status-check-failed"
  alarm_description = join(" ", compact(["An EC2 instance in this group failed its instance or system status check for ${var.period * var.datapoints_to_alarm / 60} minutes. A failed system check is an AWS host problem (stop and start moves the instance); a failed instance check is inside the OS (memory, disk, kernel).", var.description_suffix]))

  metric_query = concat(
    [{
      id          = "agg"
      expression  = "MAX([${join(",", [for i, id in local.instances : "m${i}"])}])"
      label       = "Status check failed (worst instance)"
      return_data = true
    }],
    [for i, id in local.instances : {
      id          = "m${i}"
      return_data = false
      metric = [{
        namespace   = "AWS/EC2"
        metric_name = "StatusCheckFailed"
        stat        = "Maximum"
        period      = var.period
        dimensions  = { InstanceId = id }
      }]
    }]
  )

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "missing"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  tags          = var.tags
}
