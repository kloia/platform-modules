resource "aws_organizations_organizational_unit" "new" {
  name      = var.ou_name
  parent_id = data.aws_organizations_organizational_units.ou.parent_id
}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}