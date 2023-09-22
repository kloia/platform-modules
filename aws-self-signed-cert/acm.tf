resource "aws_acm_certificate" "default" {
  count             = local.acm_enabled ? 1 : 0
  private_key       = local.tls_key
  certificate_body  = local.tls_certificate
  certificate_chain = var.basic_constraints.ca ? null : var.certificate_chain.cert_pem
}
