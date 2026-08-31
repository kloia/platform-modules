locals {
  # One entry per (access entry, policy association) pair, keyed so that two
  # entries may associate the same policy without colliding. The "<entry>_<policy>"
  # format matches the aws-eks module, so a consumer that later moves to its
  # built-in access_entries input can do so with a plain state move.
  policy_associations = merge([
    for entry_key, entry in var.access_entries : {
      for policy_key, policy in entry.policy_associations :
      "${entry_key}_${policy_key}" => {
        principal_arn = entry.principal_arn
        policy_arn    = policy.policy_arn
        scope_type    = policy.access_scope.type
        namespaces    = policy.access_scope.namespaces
      }
    }
  ]...)
}

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name  = var.cluster_name
  principal_arn = each.value.principal_arn
  type          = each.value.type

  # Both are rejected by the API for the EC2*/FARGATE/HYBRID node types, which
  # derive their identity from the node bootstrap instead. var.access_entries
  # validates that combination rather than silently dropping the values here.
  kubernetes_groups = each.value.kubernetes_groups
  user_name         = each.value.user_name

  tags = merge(var.tags, each.value.tags)
}

resource "aws_eks_access_policy_association" "this" {
  for_each = local.policy_associations

  cluster_name  = var.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.scope_type
    namespaces = each.value.namespaces
  }

  depends_on = [aws_eks_access_entry.this]
}
