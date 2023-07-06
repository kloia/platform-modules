resource "aws_route53_zone" "this" {
  for_each = { for k, v in var.zones : k => v if lookup(v, "create_zone", false) }

  name          = lookup(each.value, "domain_name", each.key)
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  delegation_set_id = lookup(each.value, "delegation_set_id", null)

  dynamic "vpc" {
    for_each = try(tolist(lookup(each.value, "vpc", [])), [lookup(each.value, "vpc", {})])

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "vpc_region", null)
    }
  }

  tags = merge(
    lookup(each.value, "tags", {}),
    var.tags
  )
}

resource "aws_route53_zone" "cross_account_this" {
  provider = aws.shared_infra
  for_each = { for k, v in var.zones : k => v if lookup(v, "create_cross_account", false) }

  name          = lookup(each.value, "domain_name", each.key)
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  delegation_set_id = lookup(each.value, "delegation_set_id", null)

  dynamic "vpc" {
    for_each = try(tolist(lookup(each.value, "vpc", [])), [lookup(each.value, "vpc", {})])

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "vpc_region", null)
    }
  }

  tags = merge(
    lookup(each.value, "tags", {}),
    var.tags
  )
}

data "aws_route53_zone" "this" {
  for_each = { for k, v in var.zones : k => v if lookup(v, "create_data_zone",false)}

  name         =  lookup(each.value, "domain_name", each.key)
  private_zone =  lookup(each.value, "private_zone", true)
}
