resource "aws_shield_protection_group" "all" {
  protection_group_id = var.group_id
  aggregation         = var.aggregation
  pattern             = "ALL"

  tags = local.tags
}