terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # rule_action_override + managed_rule_group_configs.aws_managed_rules_anti_ddos_rule_set
      # require v6.1.0 (https://github.com/hashicorp/terraform-provider-aws/blob/v6.1.0/CHANGELOG.md,
      # PR #43149). Callers not using those fields still work on older 6.x,
      # but pinning here prevents a stale lock file from silently resolving
      # a provider that predates this schema.
      version = ">= 6.1.0"
    }
  }
}
