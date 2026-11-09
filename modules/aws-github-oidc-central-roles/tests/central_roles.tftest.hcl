mock_provider "aws" {}

variables {
  name_prefix              = "Example"
  account_class            = "NonProd"
  github_organization      = "example-org"
  plan_repositories        = ["platform-example"]
  apply_repositories       = ["platform-example"]
  apply_environments       = ["iac-nonprod"]
  github_oidc_provider_arn = "arn:aws:iam::111111111111:oidc-provider/token.actions.githubusercontent.com"
  target_plan_role_name    = "ExampleTargetPlanRole"
  target_apply_role_name   = "ExampleTargetApplyRole"
  target_plan_role_arns    = ["arn:aws:iam::222222222222:role/ExampleTargetPlanRole"]
  target_apply_role_arns   = ["arn:aws:iam::222222222222:role/ExampleTargetApplyRole"]
}

run "names_follow_prefix_and_class" {
  command = plan

  assert {
    condition     = aws_iam_role.plan.name == "ExamplePlanNonProdRole" && aws_iam_role.apply.name == "ExampleApplyNonProdRole"
    error_message = "Role names must be <prefix>Plan|Apply<account_class>Role."
  }

  assert {
    condition     = aws_iam_role_policy.plan.name == "ExamplePlanNonProdAssumeTargetPlanRole" && aws_iam_role_policy.apply.name == "ExampleApplyNonProdAssumeTargetExecRole"
    error_message = "Inline policy names must follow the prefix and class."
  }

  assert {
    condition     = jsondecode(aws_iam_role.plan.assume_role_policy).Statement[0].Sid == "ExamplePlanOidcTrust"
    error_message = "Trust statement Sid must follow the prefix."
  }
}

run "plan_trust_has_pull_request_and_ref_subjects" {
  command = plan

  assert {
    condition     = strcontains(aws_iam_role.plan.assume_role_policy, "repo:example-org/platform-example:pull_request")
    error_message = "Plan trust must include the pull_request subject."
  }

  assert {
    condition     = strcontains(aws_iam_role.plan.assume_role_policy, "repo:example-org/platform-example:ref:refs/heads/main")
    error_message = "Plan trust must include the default-branch ref subject."
  }

  assert {
    condition     = !strcontains(aws_iam_role.plan.assume_role_policy, "repo:example-org/*")
    error_message = "Plan trust must enumerate repositories."
  }
}

run "apply_trust_uses_environment_subjects_only" {
  command = plan

  assert {
    condition     = strcontains(aws_iam_role.apply.assume_role_policy, "repo:example-org/platform-example:environment:iac-nonprod")
    error_message = "Apply trust must include the protected-environment subject."
  }

  assert {
    condition     = !strcontains(aws_iam_role.apply.assume_role_policy, "pull_request")
    error_message = "Apply trust must not use the pull_request subject."
  }
}

run "plan_repositories_wildcard_is_rejected" {
  command = plan

  variables {
    plan_repositories = ["*"]
  }

  expect_failures = [var.plan_repositories]
}

run "apply_repositories_with_org_prefix_is_rejected" {
  command = plan

  variables {
    apply_repositories = ["example-org/platform-example"]
  }

  expect_failures = [var.apply_repositories]
}

run "plan_workflow_dispatch_ref_wildcard_is_rejected" {
  command = plan

  variables {
    plan_workflow_dispatch_ref = "refs/heads/*"
  }

  expect_failures = [var.plan_workflow_dispatch_ref]
}

run "apply_environment_wildcard_is_rejected" {
  command = plan

  variables {
    apply_environments = ["*"]
  }

  expect_failures = [var.apply_environments]
}

run "target_arn_with_wrong_role_name_is_rejected" {
  command = plan

  variables {
    target_plan_role_arns = ["arn:aws:iam::222222222222:role/ExampleTargetApplyRole"]
  }

  expect_failures = [var.target_plan_role_arns]
}

run "policies_name_only_their_own_targets" {
  command = plan

  assert {
    condition     = toset(jsondecode(aws_iam_role_policy.plan.policy).Statement[0].Resource) == toset(var.target_plan_role_arns)
    error_message = "Plan policy Resource must equal target_plan_role_arns exactly."
  }

  assert {
    condition     = toset(jsondecode(aws_iam_role_policy.apply.policy).Statement[0].Resource) == toset(var.target_apply_role_arns)
    error_message = "Apply policy Resource must equal target_apply_role_arns exactly."
  }

  assert {
    condition     = !strcontains(aws_iam_role_policy.plan.policy, ":role/ExampleTargetApplyRole") && !strcontains(aws_iam_role_policy.apply.policy, ":role/ExampleTargetPlanRole")
    error_message = "Plan and apply policies must not reference each other's targets."
  }
}
