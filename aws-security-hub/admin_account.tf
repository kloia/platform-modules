##################################################
# Security Hub Delegated Admin
##################################################
resource "aws_securityhub_organization_admin_account" "this" {
  provider = aws.security_account
  count            = var.admin_account_id == null ? 0 : 1
  admin_account_id = var.admin_account_id
}

resource "aws_organizations_delegated_administrator" "this" {
  provider = aws.organization
  account_id        = var.admin_account_id
  service_principal = "securityhub.amazonaws.com"
}

resource "aws_securityhub_organization_configuration" "this" {
  provider = aws.organization
  auto_enable           = false
  auto_enable_standards = var.auto_enable_standards

  depends_on = [aws_securityhub_organization_admin_account.this]
}