locals {
  enabled                       = var.enabled
  parameter_write               = local.enabled && !var.ignore_value_changes ? { for e in var.parameter_write : e.name => merge(var.parameter_write_defaults, merge(e, { value = try(join(",", e.value), e.value) })) } : {}
  parameter_write_ignore_values = local.enabled && var.ignore_value_changes ? { for e in var.parameter_write : e.name => merge(var.parameter_write_defaults, merge(e, { value = try(join(",", e.value), e.value) })) } : {}
  parameter_read                = local.enabled ? var.parameter_read : []
}

data "aws_ssm_parameter" "read" {
  count = var.cross_account_read == false ? length(local.parameter_read) : 0
  name  = element(local.parameter_read, count.index)
}

data "aws_ssm_parameter" "cross_account_read" {
  count    = var.cross_account_read == true ? length(local.parameter_read) : 0
  name     = element(local.parameter_read, count.index)
  provider = aws.cross_account
}

resource "aws_ssm_parameter" "default" {
  for_each = local.parameter_write
  name     = each.key

  description     = each.value.description
  type            = each.value.type
  tier            = each.value.tier
  key_id          = each.value.type == "SecureString" && length(var.kms_arn) > 0 ? var.kms_arn : ""
  value           = each.value.value
  overwrite       = each.value.overwrite
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type

}

resource "aws_ssm_parameter" "ignore_value_changes" {
  for_each = local.parameter_write_ignore_values
  name     = each.key

  description     = each.value.description
  type            = each.value.type
  tier            = each.value.tier
  key_id          = each.value.type == "SecureString" && length(var.kms_arn) > 0 ? var.kms_arn : ""
  value           = each.value.value
  overwrite       = each.value.overwrite
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type


  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
