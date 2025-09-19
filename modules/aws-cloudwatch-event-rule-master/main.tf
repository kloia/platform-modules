
/* module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby
} */

resource "aws_cloudwatch_event_rule" "default" {
  count = var.enabled == true ? 1 : 0

  name                = var.name
  description         = var.description
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression
  role_arn            = var.role_arn
  is_enabled          = var.is_enabled
  #tags                = module.labels.tags
}

#Module      : CLOUDWATCH EVENT TARGET
#Description : Terraform module creates Cloudwatch Event Target on AWS.
resource "aws_cloudwatch_event_target" "default" {
  count      = var.enabled == true ? 1 : 0
  rule       = aws_cloudwatch_event_rule.default.*.name[0]
  target_id  = var.target_id
  arn        = var.arn
  input_path = var.input_path != "" ? var.input_path : null
  role_arn   = var.target_role_arn

  dynamic "input_transformer" {
    for_each = var.input_template != "" && length(keys(var.input_paths)) > 0 ? [true]: []

    content {
      input_paths    = var.input_path == "" ? var.input_paths : null
      input_template = var.input_path == "" ? var.input_template : null
    }
  }
}

