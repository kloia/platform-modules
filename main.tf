# Account-level Shield Advanced subscription. This is a 1-year commitment
# billed monthly — it can't be cleanly torn down by Terraform (auto-renew
# can only be disabled in the last 30 days of the term; otherwise AWS
# Support has to be contacted), hence skip_destroy. Off by default: enable
# it explicitly per account once that account's commercial sign-off is in.
resource "aws_shield_subscription" "this" {
  count = var.enable_subscription ? 1 : 0

  auto_renew   = "ENABLED"
  skip_destroy = true
}

resource "aws_shield_protection" "shield" {
  for_each     = { for k, v in var.name_resource_arn_map : k => v if !lookup(v, "cross_account_shield", false) }
  name         = each.key
  resource_arn = lookup(each.value, "arn", null)
  tags         = var.tags
}

resource "aws_shield_protection" "cross_account_shield" {
  provider     = aws.shared_infra
  for_each     = { for k, v in var.name_resource_arn_map : k => v if lookup(v, "cross_account_shield", false) }
  name         = each.key
  resource_arn = lookup(each.value, "arn", null)

  tags = var.tags
}