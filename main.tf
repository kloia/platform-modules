data "aws_ssoadmin_instances" "this" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Keyed by user name, group key and permission set name, merged with what this call creates.
  user_ids = merge(
    { for k, v in data.aws_identitystore_user.existing : k => v.user_id },
    { for k, v in aws_identitystore_user.this : k => v.user_id },
  )
  group_ids = merge(
    { for k, v in data.aws_identitystore_group.existing : k => v.group_id },
    { for k, v in aws_identitystore_group.this : k => v.group_id },
  )
  permission_set_arns = merge(
    { for k, v in data.aws_ssoadmin_permission_set.existing : k => v.arn },
    { for k, v in aws_ssoadmin_permission_set.this : k => v.arn },
  )

  # Keys are built from input names only, so for_each is known at plan time.
  memberships = merge([
    for group, g in var.groups : {
      for user in g.members : "${group}/${user}" => { group = group, user = user }
    }
  ]...)

  managed_policy_attachments = merge([
    for ps, p in var.permission_sets : {
      for arn in p.managed_policy_arns : "${ps}/${arn}" => { permission_set = ps, policy_arn = arn }
    }
  ]...)

  customer_managed_policy_attachments = merge([
    for ps, p in var.permission_sets : {
      for cmp in p.customer_managed_policies : "${ps}/${cmp.name}" => { permission_set = ps, name = cmp.name, path = cmp.path }
    }
  ]...)

  account_assignments = merge([
    for a in var.account_assignments : {
      for account_id in a.account_ids :
      "${a.principal_type}:${a.principal_name}/${a.permission_set_name}/${account_id}" => {
        principal_type = a.principal_type
        principal_name = a.principal_name
        permission_set = a.permission_set_name
        account_id     = account_id
      }
    }
  ]...)
}

# Existing objects ----------------------------------------------------------------

data "aws_identitystore_user" "existing" {
  for_each          = toset(var.existing_users)
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

data "aws_identitystore_group" "existing" {
  for_each          = var.existing_groups
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }

  lifecycle {
    precondition {
      condition     = !contains(keys(var.groups), each.key)
      error_message = "Group key '${each.key}' is in both var.groups and var.existing_groups. Keys must be unique across the two."
    }
  }
}

data "aws_ssoadmin_permission_set" "existing" {
  for_each     = toset(var.existing_permission_sets)
  instance_arn = local.instance_arn
  name         = each.key
}

# Users, groups, memberships ----------------------------------------------------

resource "aws_identitystore_user" "this" {
  for_each          = var.users
  identity_store_id = local.identity_store_id

  user_name    = each.key
  display_name = coalesce(each.value.display_name, "${each.value.given_name} ${each.value.family_name}")

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    primary = each.value.email_primary
    type    = each.value.email_type
  }
}

resource "aws_identitystore_group" "this" {
  for_each          = var.groups
  identity_store_id = local.identity_store_id

  display_name = coalesce(each.value.display_name, each.key)
  description  = each.value.description
}

resource "aws_identitystore_group_membership" "this" {
  for_each          = local.memberships
  identity_store_id = local.identity_store_id

  group_id  = aws_identitystore_group.this[each.value.group].group_id
  member_id = local.user_ids[each.value.user]

  lifecycle {
    precondition {
      condition     = contains(keys(local.user_ids), each.value.user)
      error_message = "Group member '${each.value.user}' is neither in var.users nor in var.existing_users."
    }
  }
}

# Permission sets ------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "this" {
  for_each     = var.permission_sets
  instance_arn = local.instance_arn

  name             = each.key
  description      = each.value.description
  session_duration = each.value.session_duration
  relay_state      = each.value.relay_state
  tags             = each.value.tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = { for k, v in var.permission_sets : k => v if v.inline_policy != null }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = jsonencode(jsondecode(each.value.inline_policy))
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  managed_policy_arn = each.value.policy_arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = local.customer_managed_policy_attachments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  customer_managed_policy_reference {
    name = each.value.name
    path = each.value.path
  }
}

resource "aws_ssoadmin_permissions_boundary_attachment" "this" {
  for_each = { for k, v in var.permission_sets : k => v.permissions_boundary if v.permissions_boundary != null }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn

  permissions_boundary {
    managed_policy_arn = each.value.managed_policy_arn

    dynamic "customer_managed_policy_reference" {
      for_each = each.value.customer_managed_policy == null ? [] : [each.value.customer_managed_policy]
      content {
        name = customer_managed_policy_reference.value.name
        path = customer_managed_policy_reference.value.path
      }
    }
  }
}

# Account assignments --------------------------------------------------------------

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.account_assignments

  instance_arn       = local.instance_arn
  permission_set_arn = local.permission_set_arns[each.value.permission_set]

  principal_type = each.value.principal_type
  principal_id   = each.value.principal_type == "GROUP" ? local.group_ids[each.value.principal_name] : local.user_ids[each.value.principal_name]

  target_type = "AWS_ACCOUNT"
  target_id   = each.value.account_id

  lifecycle {
    precondition {
      condition     = contains(keys(local.permission_set_arns), each.value.permission_set)
      error_message = "Permission set '${each.value.permission_set}' is neither in var.permission_sets nor in var.existing_permission_sets."
    }
    precondition {
      condition     = contains(keys(each.value.principal_type == "GROUP" ? local.group_ids : local.user_ids), each.value.principal_name)
      error_message = "Principal '${each.value.principal_name}' is not a key of ${each.value.principal_type == "GROUP" ? "var.groups or var.existing_groups" : "var.users or var.existing_users"}."
    }
  }
}
