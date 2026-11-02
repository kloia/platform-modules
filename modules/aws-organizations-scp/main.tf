# Looked up only when the policy is attached to the root, so the module also
# works from a delegated administrator that only targets OUs or accounts.
data "aws_organizations_organization" "this" {
  count = var.attach_to_root ? 1 : 0
}

locals {
  target_ids = toset(concat(
    var.attach_to_root ? [one(data.aws_organizations_organization.this[*].roots[0].id)] : [],
    var.target_ids,
  ))
}

resource "aws_organizations_policy" "this" {
  name        = var.name
  description = var.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = var.content
  tags        = var.tags
}

# Attaching fails until the SERVICE_CONTROL_POLICY type is enabled on the root.
resource "aws_organizations_policy_attachment" "this" {
  for_each = local.target_ids

  policy_id = aws_organizations_policy.this.id
  target_id = each.value
}
