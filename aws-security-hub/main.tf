data "aws_region" "current" {}

locals {
  standards_subscription = {
    aws_foundational_security_best_practices = var.standards_config != null ? merge(var.standards_config.aws_foundational_security_best_practices,
      {
        arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
    }) : null
    cis_aws_foundations_benchmark_v120 = var.standards_config != null ? merge(var.standards_config.cis_aws_foundations_benchmark_v120,
      {
        arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
    }) : null
    cis_aws_foundations_benchmark_v140 = var.standards_config != null ? merge(var.standards_config.cis_aws_foundations_benchmark_v140,
      {
        arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.4.0"
    }) : null
    nist_sp_800_53_rev5 = var.standards_config != null ? merge(var.standards_config.nist_sp_800_53_rev5,
      {
        arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/nist-800-53/v/5.0.0"
    }) : null
    pci_dss = var.standards_config != null ? merge(var.standards_config.pci_dss,
      {
        arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
    }) : null
  }
}

##################################################
# Security Hub
##################################################
resource "aws_securityhub_account" "this" {
  provider = aws.security_account
  enable_default_standards  = var.enable_default_standards
  control_finding_generator = var.control_finding_generator
  auto_enable_controls      = var.auto_enable_controls
}

resource "time_sleep" "wait_securityhub_enable" {

  create_duration = "10s"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode      = var.linking_mode
  specified_regions = var.specified_regions

  provider = aws.security_account  

  depends_on = [time_sleep.wait_securityhub_enable]
}

##################################################
# Security Hub Subscriptions
##################################################
resource "aws_securityhub_product_subscription" "this" {
  for_each    = var.product_config != null ? { for product in var.product_config : product.arn => product } : {}
  
  provider = aws.security_account  
  
  product_arn = each.value.arn

  depends_on = [time_sleep.wait_securityhub_enable]
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each = var.standards_config != null ? { for standards in local.standards_subscription : standards.arn => standards if standards.enable } : {}

  provider = aws.security_account  

  standards_arn = each.value.arn

  depends_on = [time_sleep.wait_securityhub_enable]
}

##################################################
# Security Hub Action Targets
##################################################
resource "aws_securityhub_action_target" "this" {
  for_each = var.action_target != null ? { for target in var.action_target : target.identifier => target } : {}
  
  provider = aws.security_account
  
  name        = each.value.name
  identifier  = each.value.identifier
  description = each.value.description

  depends_on = [time_sleep.wait_securityhub_enable]
}
