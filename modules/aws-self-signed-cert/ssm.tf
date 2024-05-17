resource "aws_ssm_parameter" "certificate" {
  count = local.ssm_enabled ? 1 : 0

  name   = format(var.secret_path_format, lookup(var.subject, "common_name", null), var.secret_extensions.certificate)
  type   = "SecureString"
  key_id = local.certificate_backend_kms_key_id
  value  = var.certificate_backends_base64_enabled ? base64encode(local.tls_certificate) : local.tls_certificate
}

resource "aws_ssm_parameter" "private_key" {
  count = local.ssm_enabled ? 1 : 0

  name   = format(var.secret_path_format, lookup(var.subject, "common_name", null), var.secret_extensions.private_key)
  type   = "SecureString"
  key_id = local.certificate_backend_kms_key_id
  value  = var.certificate_backends_base64_enabled ? base64encode(local.tls_key) : local.tls_key
}
