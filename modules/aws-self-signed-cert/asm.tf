resource "aws_secretsmanager_secret" "certificate" {
  count = local.asm_enabled ? 1 : 0

  name                    = format(var.secret_path_format, lookup(var.subject, "common_name", null), var.secret_extensions.certificate)
  recovery_window_in_days = var.asm_recovery_window_in_days
  kms_key_id              = local.certificate_backend_kms_key_id
}

resource "aws_secretsmanager_secret_version" "certificate" {
  count = local.asm_enabled ? 1 : 0

  secret_id     = join("", aws_secretsmanager_secret.certificate.*.name)
  secret_string = var.certificate_backends_base64_enabled ? base64encode(local.tls_certificate) : local.tls_certificate
}

resource "aws_secretsmanager_secret" "private_key" {
  count = local.asm_enabled ? 1 : 0

  name                    = format(var.secret_path_format, lookup(var.subject, "common_name", null), var.secret_extensions.private_key)
  recovery_window_in_days = var.asm_recovery_window_in_days
  kms_key_id              = local.certificate_backend_kms_key_id
}

resource "aws_secretsmanager_secret_version" "private_key" {
  count = local.asm_enabled ? 1 : 0

  secret_id     = join("", aws_secretsmanager_secret.private_key.*.name)
  secret_string = var.certificate_backends_base64_enabled ? base64encode(local.tls_key) : local.tls_key
}
