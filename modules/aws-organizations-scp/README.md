# aws-organizations-scp

Creates one AWS Organizations service control policy (SCP) and attaches it to the
organization root, to OUs or to accounts. Call it once per policy.

- Run it in the management account, or in a delegated administrator for AWS Organizations
  policy management.
- Enable the `SERVICE_CONTROL_POLICY` policy type on the root before the first apply.
  The policy is created without it, but every attachment fails. This module does not
  enable it, because doing so through `aws_organizations_organization` means importing
  and owning the whole organization.
- An SCP never restricts the management account or service-linked roles. It applies to
  every other principal in the accounts below the target, including administrators and
  the root user.
- Keep the policy document in a JSON file next to the caller and pass it with `file()`,
  so the document can be reviewed and validated on its own, for example with
  `aws accessanalyzer validate-policy --policy-type SERVICE_CONTROL_POLICY`.
- Removing a target, or destroying the module, detaches the policy at once. Plan before
  every apply.

## Usage

```hcl
module "scp_deny_leave_org" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-organizations-scp/v0.1.0"

  name           = "deny-leave-organization"
  description    = "Member accounts cannot leave the organization"
  content        = file("${path.module}/policies/deny-leave-organization.json")
  attach_to_root = true
}

module "scp_region_restriction" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-organizations-scp/v0.1.0"

  name       = "region-restriction"
  content    = file("${path.module}/policies/region-restriction.json")
  target_ids = ["ou-abcd-11111111", "ou-abcd-22222222"]
}
```

`attach_to_root` looks up the root ID with `aws_organizations_organization`, which needs
`organizations:DescribeOrganization`.
