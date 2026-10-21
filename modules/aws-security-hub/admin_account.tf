##################################################
# Security Hub Delegated Admin
##################################################
resource "aws_securityhub_organization_admin_account" "this" {
  provider         = aws.security_account
  count            = var.admin_account_id == null ? 0 : 1
  admin_account_id = var.admin_account_id
}

resource "aws_organizations_delegated_administrator" "this" {
  provider          = aws.organization
  count             = var.admin_account_id == null ? 0 : 1
  account_id        = var.admin_account_id
  service_principal = "securityhub.amazonaws.com"
}

resource "aws_securityhub_organization_configuration" "this" {
  provider              = aws.organization
  count                 = var.admin_account_id == null ? 0 : 1
  auto_enable           = false
  auto_enable_standards = var.auto_enable_standards

  depends_on = [aws_securityhub_organization_admin_account.this]
}

# Keeps existing delegated-admin resources in place now that they have a count.
moved {
  from = aws_organizations_delegated_administrator.this
  to   = aws_organizations_delegated_administrator.this[0]
}

moved {
  from = aws_securityhub_organization_configuration.this
  to   = aws_securityhub_organization_configuration.this[0]
}
