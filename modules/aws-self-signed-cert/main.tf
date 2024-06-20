locals {
  create_private_key             = try(length(var.private_key_contents), 0) == 0
  certificate_backends_enabled   = var.certificate_backends_enabled
  certificate_backend_kms_key_id = try(length(var.certificate_backend_kms_key_id), 0) > 0 ? var.certificate_backend_kms_key_id : null
  ssm_enabled                    = local.certificate_backends_enabled && contains(var.certificate_backends, "SSM")
  acm_enabled                    = local.certificate_backends_enabled && contains(var.certificate_backends, "ACM")
  asm_enabled                    = local.certificate_backends_enabled && contains(var.certificate_backends, "ASM")
  tls_certificate                = try(tls_self_signed_cert.default[0].cert_pem, tls_locally_signed_cert.default[0].cert_pem, null)
  tls_key                        = try(tls_private_key.default[0].private_key_pem, var.private_key_contents)
}

resource "tls_private_key" "default" {
  count = local.create_private_key ? 1 : 0

  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_algorithm == "ECDSA" ? var.private_key_ecdsa_curve : null
  rsa_bits    = var.private_key_algorithm == "RSA" ? var.private_key_rsa_bits : null
}

resource "tls_cert_request" "default" {
  count = var.use_locally_signed ? 1 : 0

  private_key_pem = coalesce(join("", tls_private_key.default.*.private_key_pem), var.private_key_contents)

  subject {
    common_name         = lookup(var.subject, "common_name", null)
    organization        = lookup(var.subject, "organization", null)
    organizational_unit = lookup(var.subject, "organizational_unit", null)
    street_address      = lookup(var.subject, "street_address", null)
    locality            = lookup(var.subject, "locality", null)
    province            = lookup(var.subject, "province", null)
    country             = lookup(var.subject, "country", null)
    postal_code         = lookup(var.subject, "postal_code", null)
    serial_number       = lookup(var.subject, "serial_number", null)
  }
}

resource "tls_locally_signed_cert" "default" {
  count = var.use_locally_signed ? 1 : 0

  is_ca_certificate = var.basic_constraints.ca

  cert_request_pem   = join("", tls_cert_request.default.*.cert_request_pem)
  ca_private_key_pem = var.certificate_chain.private_key_pem
  ca_cert_pem        = var.certificate_chain.cert_pem

  validity_period_hours = var.validity.duration_hours
  early_renewal_hours   = var.validity.early_renewal_hours

  allowed_uses       = var.allowed_uses
  set_subject_key_id = var.skid_enabled
}

resource "tls_self_signed_cert" "default" {
  count = !var.use_locally_signed ? 1 : 0

  is_ca_certificate = var.basic_constraints.ca

  private_key_pem = coalesce(join("", tls_private_key.default.*.private_key_pem), var.private_key_contents)

  validity_period_hours = var.validity.duration_hours
  early_renewal_hours   = var.validity.early_renewal_hours

  allowed_uses = var.allowed_uses

  subject {
    common_name         = lookup(var.subject, "common_name", null)
    organization        = lookup(var.subject, "organization", null)
    organizational_unit = lookup(var.subject, "organizational_unit", null)
    street_address      = lookup(var.subject, "street_address", null)
    locality            = lookup(var.subject, "locality", null)
    province            = lookup(var.subject, "province", null)
    country             = lookup(var.subject, "country", null)
    postal_code         = lookup(var.subject, "postal_code", null)
    serial_number       = lookup(var.subject, "serial_number", null)
  }

  dns_names    = var.subject_alt_names.dns_names
  ip_addresses = var.subject_alt_names.ip_addresses
  uris         = var.subject_alt_names.uris

  set_subject_key_id = var.skid_enabled
}
