# aws-eks-access-entry

Manages EKS **access entries** and **access policy associations** for an existing
cluster, independently of the module that created the cluster.

`aws-eks` only gained an `access_entries` input in `module/aws-eks/v0.3.0`. Clusters
still pinned to `v0.2.x` have no way to declare an access entry in code, so their
entries end up created by hand in the console. This module closes that gap without
requiring a cluster-module upgrade — the EKS v19 → v20 jump that `v0.3.x` carries is
a large change to make on a live cluster.

Use it when:

* the cluster is on `aws-eks` `v0.2.x`, or
* access entries are owned by a different team or lifecycle than the cluster itself.

If the cluster is already on `aws-eks` `v0.3.x`, prefer that module's own
`access_entries` input — this module takes the same shape, so moving between the two
is a `terraform state mv`.

## Usage

### Bind a principal to your own RBAC via a Kubernetes group

The AWS-managed access policies are coarse: `AmazonEKSViewPolicy` maps to the built-in
`view` ClusterRole, which grants `pods/log` and `configmaps`. When that is more than
you want, place the principal in a Kubernetes group and bind your own ClusterRole to it.

```hcl
module "eks_access_entry" {
  source = "git@github.com:kloia/platform-modules.git/?ref=module/aws-eks-access-entry/v0.1.0"

  cluster_name = "my-cluster"

  access_entries = {
    inventory_readonly = {
      # IAM Identity Center roles keep their full path here — do not strip it.
      principal_arn     = "arn:aws:iam::111122223333:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_MyPermissionSet_0123456789abcdef"
      kubernetes_groups = ["platform:inventory-readonly"]
    }
  }

  tags = {
    Environment = "prod"
    Project     = "platform"
  }
}
```

The `ClusterRole` and `ClusterRoleBinding` for `platform:inventory-readonly` are not
created here — this module only manages the AWS side of the mapping.

### Associate an AWS-managed access policy

```hcl
access_entries = {
  cluster_admin = {
    principal_arn = "arn:aws:iam::111122223333:role/PlatformAdmin"

    policy_associations = {
      admin = {
        policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = { type = "cluster" }
      }
    }
  }

  team_namespace_view = {
    principal_arn = "arn:aws:iam::111122223333:role/TeamViewer"

    policy_associations = {
      view = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
        access_scope = {
          type       = "namespace"
          namespaces = ["team-a", "team-b"]
        }
      }
    }
  }
}
```

### Node group entries

```hcl
access_entries = {
  linux_nodes = {
    principal_arn = aws_iam_role.node_group.arn
    type          = "EC2_LINUX"
  }
}
```

`kubernetes_groups` and `user_name` are rejected by the API for the node types and are
validated against here.

## Notes

* The cluster must have `authentication_mode` set to `API` or `API_AND_CONFIG_MAP`.
  Access entries are ignored under `CONFIG_MAP`.
* An access entry with neither `kubernetes_groups` nor `policy_associations` grants
  nothing. That is a valid state, not an error.
* Only one access entry may exist per principal ARN per cluster. Importing an entry
  created by hand is `terraform import module.x.aws_eks_access_entry.this[\"key\"] <cluster>:<principal-arn>`.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|:---:|
| `cluster_name` | Name of the EKS cluster the access entries belong to. | `string` | n/a | yes |
| `access_entries` | Map of access entries to create, keyed by an arbitrary name. | `map(object)` | `{}` | no |
| `tags` | Tags applied to every access entry, merged with each entry's own tags. | `map(string)` | `{}` | no |

### `access_entries` object

| Attribute | Description | Type | Default |
|---|---|---|---|
| `principal_arn` | IAM role or user ARN. IAM Identity Center roles keep their full path. | `string` | n/a |
| `type` | `STANDARD`, `EC2`, `EC2_LINUX`, `EC2_WINDOWS`, `FARGATE_LINUX` or `HYBRID_LINUX`. | `string` | `"STANDARD"` |
| `kubernetes_groups` | Groups the principal is placed in. `STANDARD` only. | `list(string)` | `null` |
| `user_name` | Kubernetes username for the principal. `STANDARD` only. | `string` | `null` |
| `tags` | Tags for this entry, merged over `var.tags`. | `map(string)` | `{}` |
| `policy_associations` | AWS-managed cluster access policies to associate. | `map(object)` | `{}` |

### `policy_associations` object

| Attribute | Description | Type | Default |
|---|---|---|---|
| `policy_arn` | `arn:aws:eks::aws:cluster-access-policy/...` | `string` | n/a |
| `access_scope.type` | `cluster` or `namespace`. | `string` | n/a |
| `access_scope.namespaces` | Required, non-empty, when `type` is `namespace`. | `list(string)` | `null` |

## Outputs

| Name | Description |
|---|---|
| `access_entries` | Map of the created access entries, keyed as given in `var.access_entries`. |
| `access_entry_arns` | Map of access entry key to the ARN of the access entry. |
| `access_policy_associations` | Map of the created associations, keyed `"<entry key>_<policy key>"`. |
