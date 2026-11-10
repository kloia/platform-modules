# aws-github-oidc-central-roles

One central role pair (plan and apply) for one tier, assumed by GitHub Actions through OIDC and
allowed to assume per-account Terraform roles. Call it once per tier (`NonProd`, `Prod`) in the
account that holds the GitHub OIDC provider.

```
GitHub OIDC token -> <prefix>Plan<Tier>Role  -> <account>:role/<target_plan_role_name>   (plan)
                  -> <prefix>Apply<Tier>Role -> <account>:role/<target_apply_role_name>  (apply)
```

- **Plan role** trusts each listed repository's `pull_request` subject and its default-branch
  `ref:` subject. Its inline policy may assume only `target_plan_role_arns`.
- **Apply role** trusts each listed repository's `environment:<name>` subject for the listed
  protected GitHub Environments. Its inline policy may assume only `target_apply_role_arns`.
- Repositories, environments and the ref are validated so a subject can never become a wildcard.

Onboarding a repository adds it to `plan_repositories` / `apply_repositories`; a new target
account adds its role ARNs to the target lists. The target roles must trust these central roles
on their side as well.

**Apply it by hand with administrator credentials.** A pipeline that authenticates through these
roles cannot be the thing that changes them.

## Usage

```hcl
module "central_roles_nonprod" {
  source = "git::https://github.com/kloia/platform-modules.git//modules/aws-github-oidc-central-roles?ref=<tag>"

  name_prefix              = "Example"
  account_class            = "NonProd"
  github_organization      = "example-org"
  github_oidc_provider_arn = "arn:aws:iam::111111111111:oidc-provider/token.actions.githubusercontent.com"

  plan_repositories  = ["platform-example"]
  apply_repositories = ["platform-example"]
  apply_environments = ["iac-nonprod"]

  target_plan_role_name  = "ExampleTargetPlanRole"
  target_apply_role_name = "ExampleTargetApplyRole"
  target_plan_role_arns  = ["arn:aws:iam::222222222222:role/ExampleTargetPlanRole"]
  target_apply_role_arns = ["arn:aws:iam::222222222222:role/ExampleTargetApplyRole"]

  max_session_duration = 4500
}
```

## Adopting existing roles

Role, policy and statement names derive from `name_prefix` and `account_class`. To bring roles
created elsewhere under this module, set the prefix that reproduces their names and import the
four resources (`aws_iam_role.plan`, `aws_iam_role_policy.plan`, `aws_iam_role.apply`,
`aws_iam_role_policy.apply`); a wrong prefix plans a replacement instead.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name_prefix` | Prefix for role, inline policy and Sid names | required |
| `account_class` | `NonProd` or `Prod` | required |
| `github_organization` | GitHub organization of the repositories | required |
| `github_oidc_provider_arn` | Existing GitHub OIDC provider ARN in this account | required |
| `plan_repositories` | Bare repository names trusted by the plan role | required |
| `plan_workflow_dispatch_ref` | Default-branch ref trusted by the plan role | `"refs/heads/main"` |
| `apply_repositories` | Bare repository names trusted by the apply role | required |
| `apply_environments` | Protected GitHub Environments trusted by the apply role | required |
| `target_plan_role_arns` | Target plan roles the plan role may assume | required |
| `target_apply_role_arns` | Target apply roles the apply role may assume | required |
| `target_plan_role_name` | Required name of every target plan role | required |
| `target_apply_role_name` | Required name of every target apply role | required |
| `max_session_duration` | Session length in seconds for both roles | `3600` |
| `tags` | Tags on both roles | `{}` |

## Outputs

`plan_role_arn`, `plan_role_name`, `apply_role_arn`, `apply_role_name`.

## Tests

```bash
terraform init -backend=false && terraform test
```

The tests run offline against a mock provider.
