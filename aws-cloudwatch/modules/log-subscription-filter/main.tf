resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each        = toset(var.log_group_names)
  name            = "LamdaFuncFilter-${each.key}"
  role_arn        = var.role_arn
  log_group_name  = each.value
  filter_pattern  = var.filter_pattern
  destination_arn = var.destination_arn
}