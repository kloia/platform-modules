
locals {
  port = coalesce(var.port, (var.engine == "aurora-postgresql" ? 5432 : 1433))
}



################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : var.name
  name_prefix = var.security_group_use_name_prefix ? "${var.name}-sql-server" : null
  vpc_id      = var.vpc_id
  description = coalesce(var.security_group_description, "Control traffic to/from RDS Aurora ${var.name}")

  tags = merge(var.tags, var.security_group_tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
  }
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "default_ingress" {
  count = var.create_security_group ? length(var.allowed_security_groups) : 0

  description = "From allowed SGs"

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.this[0].id
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "cidr_ingress" {
  count = var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this[0].id
}

resource "aws_security_group_rule" "egress" {
  for_each = var.create_security_group ? var.security_group_egress_rules : {}

  # required
  type              = "egress"
  from_port         = try(each.value.from_port, local.port)
  to_port           = try(each.value.to_port, local.port)
  protocol          = try(each.value.protocol, null)
  security_group_id = aws_security_group.this[0].id

  # optional
  cidr_blocks              = try(each.value.cidr_blocks, null)
  description              = try(each.value.description, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}


#############################
# Amazon RDS for SQL Server #
#############################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "monitoring.rds.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "monitoring_role" {
  name                = "${var.name}-monitoring-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}


resource "aws_db_option_group" "this" {
  count                    = var.enable_custom_option_group ? 1 : 0
  name                     = "${var.db_group_name}-option-group"
  option_group_description = "RDS SSRS and SSIS Option Group"
  engine_name              = var.engine
  major_engine_version     = var.option_group_engine_version

  option {
    option_name = var.option_name
  }

  dynamic "option" {
    for_each = var.enable_custom_option_group ? var.option_group : []

    content {
      option_name                    = option.value.option_name
      vpc_security_group_memberships = var.allowed_security_groups
      #db_security_group_memberships  = var.allowed_security_groups
      dynamic "option_settings" {
        for_each = can(option.value.option_rule_names[*]) ? option.value.option_rule_names : null
        content {
          name  = option_settings.value.rule_name
          value = option_settings.value.option_rule_value
        }
      }
    }
  }
}


resource "aws_db_parameter_group" "sql_server" {
  count  = var.enable_custom_parameter_group ? 1 : 0
  name   = "${var.db_group_name}-paramater-group"
  family = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = var.enable_custom_parameter_group ? var.parameter_group : []
    content {
      name         = parameter.value.parameter_name
      value        = parameter.value.parameter_value
      apply_method = parameter.value.parameter_apply_method
    }
  }
}

resource "aws_db_instance" "rds_sql_server_read_replica" {

  engine         = var.engine
  engine_version = var.engine_version
  port           = 1433

  identifier = var.instances_use_identifier_prefix ? null : "${var.name}-sql-server"

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately


  maintenance_window  = var.preferred_maintenance_window
  deletion_protection = var.deletion_protection

  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  skip_final_snapshot   = var.skip_final_snapshot

  instance_class       = var.instance_class
  kms_key_id           = var.kms_key_id
  parameter_group_name = var.enable_custom_parameter_group ? aws_db_parameter_group.sql_server[0].name : var.db_parameter_group_name
  option_group_name    = var.enable_custom_option_group ? aws_db_option_group.this[0].name : var.db_parameter_group_name

  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  max_allocated_storage = var.max_allocated_storage

  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = aws_iam_role.monitoring_role.arn
  performance_insights_enabled    = var.performance_insights_enabled
  enabled_cloudwatch_logs_exports = var.logs_exports



  vpc_security_group_ids = compact(concat([try(aws_security_group.this[0].id, "")], var.vpc_security_group_ids))

  replicate_source_db = var.replication_source_identifier

  timeouts {
    create = "80m"
  }

  tags       = var.tags
}

