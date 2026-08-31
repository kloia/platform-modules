variable "cluster_name" {
  description = "Name of the EKS cluster the access entries belong to."
  type        = string
}

variable "access_entries" {
  description = <<-EOT
    Map of access entries to create on the cluster, keyed by an arbitrary name.

    Attach Kubernetes permissions in one of two ways:
      * `kubernetes_groups` — the principal is placed in those groups, and you
        bind your own ClusterRole/Role to them. Use this when the AWS-managed
        access policies grant more than you want.
      * `policy_associations` — associate an AWS-managed cluster access policy
        (`arn:aws:eks::aws:cluster-access-policy/...`), optionally scoped to
        namespaces.

    Both may be set on the same entry; the principal receives the union.
  EOT

  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    kubernetes_groups = optional(list(string))
    user_name         = optional(string)
    tags              = optional(map(string), {})
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string))
      })
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for entry in var.access_entries :
      contains(["STANDARD", "EC2", "EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX"], entry.type)
    ])
    error_message = "access_entries[*].type must be one of STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX, HYBRID_LINUX."
  }

  validation {
    condition = alltrue([
      for entry in var.access_entries :
      entry.type == "STANDARD" || (entry.kubernetes_groups == null && entry.user_name == null)
    ])
    error_message = "kubernetes_groups and user_name are only valid when type is STANDARD; the node types derive their identity from the node bootstrap."
  }

  validation {
    condition = alltrue(flatten([
      for entry in var.access_entries : [
        for policy in entry.policy_associations :
        contains(["cluster", "namespace"], policy.access_scope.type)
      ]
    ]))
    error_message = "access_scope.type must be either \"cluster\" or \"namespace\"."
  }

  validation {
    condition = alltrue(flatten([
      for entry in var.access_entries : [
        for policy in entry.policy_associations :
        policy.access_scope.type != "namespace" || try(length(policy.access_scope.namespaces), 0) > 0
      ]
    ]))
    error_message = "access_scope.namespaces must be a non-empty list when access_scope.type is \"namespace\"."
  }
}

variable "tags" {
  description = "Tags applied to every access entry, merged with each entry's own tags."
  type        = map(string)
  default     = {}
}
