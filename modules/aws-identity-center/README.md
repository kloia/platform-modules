# aws-identity-center

Manages AWS IAM Identity Center (successor to AWS SSO) objects: users, groups, group memberships,
permission sets (with managed, customer managed, inline policies and a permissions boundary) and
account assignments.

## Why native resources and not a wrapper around `aws-ia/iam-identity-center/aws`

The upstream module (v1.0.4 reviewed) was not wrapped because it cannot give this module's contract:

- Its resource keys are composite strings it builds itself (`Type:GROUP__Principal:...`,
  `<pset>.<policy_arn>`), and it nests everything one module deeper, so import addresses are not the
  human names.
- Its managed policy attachments carry `depends_on` on every account assignment, which ties the
  permission sets to the assignments and prevents the split into separate states described below.
- Existing users are only supported as group members through its Google-specific input, and inline
  policy JSON is passed through unnormalised.

This module therefore uses `aws_identitystore_*` and `aws_ssoadmin_*` resources directly, keyed by name.

## Usage

Released versions are tagged `module/aws-identity-center/vX.Y.Z`:

```hcl
module "identity_center" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-identity-center/v0.1.0"

  users = yamldecode(file("users.yaml")).users
  # ...
}
```

Terragrunt:

```hcl
terraform {
  source = "git::git@github.com:kloia/platform-modules.git?ref=module/aws-identity-center/v0.1.0"
}

inputs = yamldecode(file("identity-center.yaml"))
```

Before the first release, point at the module directory on a branch:
`git::https://github.com/kloia/platform-modules.git//modules/aws-identity-center?ref=main`.

See [`examples/complete`](./examples/complete) for a full example with placeholder data.

## Splitting across states

Every input defaults to empty, so the module can be called several times, each in its own state:

1. **Permission sets**: set `permission_sets` only.
2. **Users, groups and memberships**: set `users`, `groups` (and `existing_users` for members owned elsewhere).
3. **Assignments**: set `account_assignments` plus `existing_groups`, `existing_users` and
   `existing_permission_sets` naming everything the assignments refer to (`existing_groups` is a map of key => DisplayName). Nothing needs to be created in
   that call.

A name or key that is neither created nor looked up fails at plan time with a precondition message.
The IAM Identity Center instance and identity store are discovered with `aws_ssoadmin_instances`, so the
module must run in the Region and account that host the instance (the management account or the delegated
administrator).

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `users` | `map(object({ given_name, family_name, display_name = optional(string), email, email_type = optional(string), email_primary = optional(bool, true) }))` | `{}` | Keyed by user name. `display_name` defaults to "given family". Set `email_type` (for example `work`) and `email_primary` to match imported users whose email carries a type or is not marked primary. |
| `groups` | `map(object({ display_name = optional(string), description = optional(string), members = optional(list(string), []) }))` | `{}` | Keyed by a stable name (the resource address). `display_name` defaults to the key and can change in place. Members are user names from `users` or `existing_users`. |
| `permission_sets` | `map(object({ description, session_duration = "PT1H" (PT1H to PT12H), relay_state, managed_policy_arns = [], customer_managed_policies = [{ name, path = "/" }], inline_policy, permissions_boundary = { managed_policy_arn or customer_managed_policy = { name, path } }, tags = {} }))` | `{}` | Keyed by permission set name. All fields optional except the key. `session_duration` is `PT<h>H` or `PT<h>H<m>M`, minutes 0-59, total 1 to 12 hours (for example `PT1H`, `PT8H30M`, `PT12H`); `PT0H`, `PT90M` and `PT13H` fail validation. |
| `account_assignments` | `list(object({ principal_type, principal_name, permission_set_name, account_ids = list(string) }))` | `[]` | `principal_type` is `GROUP` or `USER`. For `GROUP`, `principal_name` is a group key: a key of `groups` or of `existing_groups`. For `USER` it is a user name from `users` or `existing_users`. |
| `existing_users` | `list(string)` | `[]` | User names to look up. |
| `existing_groups` | `map(string)` | `{}` | Groups to look up, as stable key => DisplayName. The key is what `account_assignments` refers to; the value is only used for the lookup. Keys must not also be keys of `groups`. |
| `existing_permission_sets` | `list(string)` | `[]` | Permission set names to look up. |

`inline_policy` is a JSON string. It is normalised with `jsonencode(jsondecode())`, which removes
whitespace and key-order differences between what you write and what AWS returns.

## Outputs

`instance_arn`, `identity_store_id`, `user_ids`, `group_ids`, `group_membership_ids`,
`permission_set_arns`, `inline_policy_ids`, `managed_policy_attachment_ids`,
`customer_managed_policy_attachment_ids`, `permissions_boundary_attachment_ids`,
`account_assignment_ids` (all maps of key to value for objects created by this call), and
`resolved_user_ids`, `resolved_group_ids`, `resolved_permission_set_arns` (created plus looked up).

## Resource addresses and import IDs

Every address is keyed by a human name, so `import` blocks and `terraform import` can target them.
Groups are always referred to by key: `members` lists user names, and a `GROUP` assignment's `principal_name` is a key of `groups` or of `existing_groups`. The DisplayName of an existing group appears only as the value in `existing_groups`, so a DisplayName change never alters an address.
Replace `module.identity_center.` with your module address. Import IDs use the provider's formats
(checked against the AWS provider documentation); `<ps_arn>` is the permission set ARN and `<instance_arn>`
the Identity Center instance ARN (`output.instance_arn`).

| Object | Address | Import ID |
|---|---|---|
| User | `aws_identitystore_user.this["jane.doe"]` | `<identity_store_id>/<user_id>` |
| Group | `aws_identitystore_group.this["platform-admins"]` | `<identity_store_id>/<group_id>` |
| Group membership | `aws_identitystore_group_membership.this["platform-admins/jane.doe"]` (key `<group>/<user name>`) | `<identity_store_id>/<membership_id>` |
| Permission set | `aws_ssoadmin_permission_set.this["PlatformAdmin"]` | `<ps_arn>,<instance_arn>` |
| Inline policy | `aws_ssoadmin_permission_set_inline_policy.this["PlatformAdmin"]` | `<ps_arn>,<instance_arn>` |
| Managed policy attachment | `aws_ssoadmin_managed_policy_attachment.this["PlatformAdmin/arn:aws:iam::aws:policy/AdministratorAccess"]` (key `<permission set>/<policy ARN>`) | `<policy_arn>,<ps_arn>,<instance_arn>` |
| Customer managed policy attachment | `aws_ssoadmin_customer_managed_policy_attachment.this["ReadOnlyPlus/example-extra-read"]` (key `<permission set>/<policy name>`) | `<name>,<path>,<ps_arn>,<instance_arn>` |
| Permissions boundary attachment | `aws_ssoadmin_permissions_boundary_attachment.this["PlatformAdmin"]` | `<ps_arn>,<instance_arn>` |
| Account assignment | `aws_ssoadmin_account_assignment.this["GROUP:platform-admins/PlatformAdmin/111111111111"]` (key `<GROUP or USER>:<group key or user name>/<permission set>/<account id>`) | `<principal_id>,<principal_type>,<account_id>,AWS_ACCOUNT,<ps_arn>,<instance_arn>` |

Notes:

- The membership ID is not the user ID. List it with
  `aws identitystore list-group-memberships --identity-store-id <id> --group-id <group_id>`.
- The customer managed policy key ignores `path`; a permission set cannot reference two customer managed
  policies of the same name anyway.
- Lookups (`existing_*`) are data sources and have nothing to import.

Example import block:

```hcl
import {
  to = module.identity_center.aws_identitystore_user.this["jane.doe"]
  id = "d-0123456789/11111111-2222-3333-4444-555555555555"
}
```

## Renames

- **Group**: change `display_name` in the `groups` entry. The map key stays, so the group is updated in
  place, keeps its group ID, and memberships and assignments are untouched. Without `display_name` the
  key is the display name, so renaming a key (not `display_name`) replaces the group.
- **Existing (looked-up) group**: change the DisplayName value in `existing_groups` and keep the key.
  Only the data lookup changes; assignments keep their address, so nothing is destroyed or created.
  Renaming the key instead changes every assignment address that uses it.
- **User**: `user_name` is ForceNew in the provider. Renaming the key is a remove plus add, with a new
  user ID, new memberships and new USER assignments.
- **Permission set**: `name` is ForceNew. A rename creates a new permission set (new ARN). A provisioned
  permission set that still has account assignments cannot be deleted until they are removed.
- Because assignments are destroyed and created around a rename, do it in this order: add the new
  object, move assignments to it, then remove the old one.
- `moved` blocks only help when a key changes for the same object (a pure address rename). They cannot
  carry an object across a ForceNew attribute change.

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3.0 |
| aws | >= 5.40 |
