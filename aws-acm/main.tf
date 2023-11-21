locals {
  create_certificate          = var.create_certificate
  create_route53_records_only = var.create_route53_records_only

  # Get distinct list of domains and SANs
  distinct_domain_names = coalescelist(var.distinct_domain_names, distinct(
    [for s in concat([var.domain_name], var.subject_alternative_names) : replace(s, "*.", "")]
  ))

  # Get the list of distinct domain_validation_options, with wildcard
  # domain names replaced by the domain name
  validation_domains = local.create_certificate || local.create_route53_records_only ? distinct(
    [for k, v in try(aws_acm_certificate.this[0].domain_validation_options, var.acm_certificate_domain_validation_options) : merge(
      tomap(v), { domain_name = replace(v.domain_name, "*.", "") }
    )]
  ) : []
}

resource "aws_acm_certificate" "this" {
  count = local.create_certificate ? 1 : 0
  provider = aws.aws_acm

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  dynamic "validation_option" {
    for_each = var.validation_option

    content {
      domain_name       = try(validation_option.value["domain_name"], validation_option.key)
      validation_domain = validation_option.value["validation_domain"]
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  count = (local.create_certificate || local.create_route53_records_only) && var.validation_method == "DNS" && var.create_route53_records && (var.validate_certificate || local.create_route53_records_only) ? length(local.distinct_domain_names) : 0
  provider = aws.shared_infra
  name         = "${var.domain_name}"
  private_zone = false
}

resource "aws_route53_record" "validation" {
  provider = aws.shared_infra
  count = (local.create_certificate || local.create_route53_records_only) && var.validation_method == "DNS" && var.create_route53_records && (var.validate_certificate || local.create_route53_records_only) ? length(local.distinct_domain_names) : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = element(local.validation_domains, count.index)["resource_record_name"]
  type    = element(local.validation_domains, count.index)["resource_record_type"]
  ttl     = var.dns_ttl

  records = [
    element(local.validation_domains, count.index)["resource_record_value"]
  ]

  allow_overwrite = var.validation_allow_overwrite_records

  depends_on = [aws_acm_certificate.this]
}

resource "aws_acm_certificate_validation" "this" {
  count = local.create_certificate && var.validation_method != "NONE" && var.validate_certificate && var.wait_for_validation ? 1 : 0
  provider = aws.aws_acm

  certificate_arn = aws_acm_certificate.this[0].arn

  validation_record_fqdns = flatten([aws_route53_record.validation.*.fqdn, var.validation_record_fqdns])
}
