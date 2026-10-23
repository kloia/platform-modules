# Looked up only when the caller does not pass detector_id. The data source
# fails at plan time if the account has no detector in this Region yet.
data "aws_guardduty_detector" "this" {
  count = var.detector_id == null ? 1 : 0
}

locals {
  detector_id = coalesce(var.detector_id, one(data.aws_guardduty_detector.this[*].id))
}

resource "aws_guardduty_detector_feature" "this" {
  for_each = var.features

  detector_id = local.detector_id
  name        = each.key
  status      = each.value.status

  dynamic "additional_configuration" {
    for_each = each.value.additional_configuration
    content {
      name   = additional_configuration.key
      status = additional_configuration.value
    }
  }
}
