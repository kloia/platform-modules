locals {
  plan_role_name  = "${var.name_prefix}Plan${var.account_class}Role"
  apply_role_name = "${var.name_prefix}Apply${var.account_class}Role"

  # The plan role is assumed by PR plan jobs (pull_request subject) and by
  # read-only jobs that run from the default branch (ref subject). Both are
  # enumerated per repository, never a wildcard.
  plan_subjects = concat(
    [for repo in var.plan_repositories : "repo:${var.github_organization}/${repo}:pull_request"],
    [for repo in var.plan_repositories : "repo:${var.github_organization}/${repo}:ref:${var.plan_workflow_dispatch_ref}"],
  )

  apply_subjects = flatten([
    for repo in var.apply_repositories : [
      for env in var.apply_environments : "repo:${var.github_organization}/${repo}:environment:${env}"
    ]
  ])

  # jsonencode() rather than aws_iam_policy_document so `terraform test` can assert
  # the rendered policies under mock_provider, where data sources return no JSON.
  plan_trust_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "${var.name_prefix}PlanOidcTrust"
        Effect    = "Allow"
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = { Federated = var.github_oidc_provider_arn }
        Condition = {
          StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
          StringLike   = { "token.actions.githubusercontent.com:sub" = local.plan_subjects }
        }
      }
    ]
  })

  apply_trust_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "${var.name_prefix}ApplyOidcTrust"
        Effect    = "Allow"
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = { Federated = var.github_oidc_provider_arn }
        Condition = {
          StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
          StringLike   = { "token.actions.githubusercontent.com:sub" = local.apply_subjects }
        }
      }
    ]
  })

  plan_permissions_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AssumeTargetPlanRoles"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.target_plan_role_arns
      }
    ]
  })

  apply_permissions_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AssumeTargetExecRoles"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.target_apply_role_arns
      }
    ]
  })
}

resource "aws_iam_role" "plan" {
  name                 = local.plan_role_name
  assume_role_policy   = local.plan_trust_json
  max_session_duration = var.max_session_duration
  tags                 = var.tags
}

resource "aws_iam_role_policy" "plan" {
  name   = "${var.name_prefix}Plan${var.account_class}AssumeTargetPlanRole"
  role   = aws_iam_role.plan.id
  policy = local.plan_permissions_json
}

resource "aws_iam_role" "apply" {
  name                 = local.apply_role_name
  assume_role_policy   = local.apply_trust_json
  max_session_duration = var.max_session_duration
  tags                 = var.tags
}

resource "aws_iam_role_policy" "apply" {
  name   = "${var.name_prefix}Apply${var.account_class}AssumeTargetExecRole"
  role   = aws_iam_role.apply.id
  policy = local.apply_permissions_json
}
