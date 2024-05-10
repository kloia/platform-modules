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