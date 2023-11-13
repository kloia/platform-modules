resource "aws_amplify_app" "this" {
  name       = var.name
  repository = var.repository

  build_spec = var.build_spec

  environment_variables = var.environment_variables

  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  enable_auto_branch_creation = try(var.enable_auto_branch_creation, false)
  enable_basic_auth           = try(var.enable_basic_auth, false)
  enable_branch_auto_build    = try(var.enable_branch_auto_build, false)
  enable_branch_auto_deletion = try(var.enable_branch_auto_deletion, false)

  iam_service_role_arn = var.iam_service_role_arn

  platform = var.platform

  dynamic "custom_rule" {
    for_each = var.custom_rules

    content {
      source = custom_rule.value["source"]
      status = custom_rule.value["status"]
      target = custom_rule.value["target"]
    }
  }

  tags = var.tags
}

resource "aws_amplify_branch" "this" {
  app_id      = aws_amplify_app.this.id
  branch_name = var.branch_name

  framework = var.framework
  stage     = var.stage

    enable_auto_build = var.enable_auto_build
    enable_performance_mode = var.enable_performance_mode
    enable_pull_request_preview = var.enable_pull_request_preview

  tags = var.tags
}

resource "aws_amplify_domain_association" "this" {
  app_id      = aws_amplify_app.this.id
  domain_name = var.domain_name

  enable_auto_sub_domain = var.enable_auto_sub_domain

  dynamic "sub_domain" {
    for_each = var.sub_domains

    content {
      branch_name = aws_amplify_branch.this.branch_name
      prefix      = try(sub_domain.value["prefix"], "")
      dns_record  = try(sub_domain.value["dns_record"], null)
    }
  }
}
