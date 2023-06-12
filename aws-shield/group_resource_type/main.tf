resource "aws_shield_protection_group" "resource_type_protection_group" {
  count               = length(var.resource_type_protection_group)
  protection_group_id = var.resource_type_protection_group.group_id
  aggregation         = var.resource_type_protection_group.aggregation
  pattern             = "BY_RESOURCE_TYPE"
  resource_type       = var.resource_type_protection_group.resource_type

  tags = local.tags
}