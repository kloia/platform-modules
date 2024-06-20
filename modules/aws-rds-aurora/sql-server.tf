#############################
# Amazon RDS for SQL Server #
#############################

resource "aws_iam_policy" "policy" {
  count       = var.rds_custom ? 1 : 0
  name        = "AWSRDSCustomSQLServerIamRolePolicy"
  path        = "/"
  description = "AWS RDS Custom SQL Server Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ssmAgent1",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:ListAssociations",
          "ssm:PutInventory",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateInstanceInformation",
          "ssm:GetManifest"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ssmAgent2",
        "Effect" : "Allow",
        "Action" : [
          "ssm:ListInstanceAssociations",
          "ssm:PutComplianceItems",
          "ssm:UpdateAssociationStatus",
          "ssm:DescribeAssociation",
          "ssm:UpdateInstanceAssociationStatus"
        ],
        "Resource" : "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*"
      },
      {
        "Sid" : "ssmAgent3",
        "Effect" : "Allow",
        "Action" : [
          "ssm:UpdateAssociationStatus",
          "ssm:DescribeAssociation",
          "ssm:GetDocument",
          "ssm:DescribeDocument"
        ],
        "Resource" : "arn:aws:ssm:*:*:document/*"
      },
      {
        "Sid" : "ssmAgent4",
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ssmAgent5",
        "Effect" : "Allow",
        "Action" : [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ssmAgent6",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:*:*:parameter/*"
      },
      {
        "Sid" : "ssmAgent7",
        "Effect" : "Allow",
        "Action" : [
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:DescribeAssociation"
        ],
        "Resource" : "arn:aws:ssm:*:*:association/*"
      },
      {
        "Sid" : "eccSnapshot1",
        "Effect" : "Allow",
        "Action" : "ec2:CreateSnapshot",
        "Resource" : [
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/*"
        ],
      },
      {
        "Sid" : "eccSnapshot2",
        "Effect" : "Allow",
        "Action" : "ec2:CreateSnapshot",
        "Resource" : [
          "arn:aws:ec2:${data.aws_region.current.name}::snapshot/*"
        ]
      },
      {
        "Sid" : "eccCreateTag",
        "Effect" : "Allow",
        "Action" : "ec2:CreateTags",
        "Resource" : "*",
      },
      {
        "Sid" : "s3BucketAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:putObject",
          "s3:getObject",
          "s3:getObjectVersion",
          "s3:AbortMultipartUpload"
        ],
        "Resource" : [
          "arn:aws:s3:::do-not-delete-rds-custom-*/*"
        ]
      },
      {
        "Sid" : "customerKMSEncryption",
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : [
          "${var.kms_key_id}"
        ]
      },
      {
        "Sid" : "readSecretsFromCP",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:do-not-delete-rds-custom-*"
        ]
      },
      {
        "Sid" : "publishCWMetrics",
        "Effect" : "Allow",
        "Action" : "cloudwatch:PutMetricData",
        "Resource" : "*"
      },
      {
        "Sid" : "putEventsToEventBus",
        "Effect" : "Allow",
        "Action" : "events:PutEvents",
        "Resource" : "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/default"
      },
      {
        "Sid" : "cwlOperations1",
        "Effect" : "Allow",
        "Action" : [
          "logs:PutRetentionPolicy",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:rds-custom-instance-*"
      },
      {
        "Action" : [
          "SQS:SendMessage",
          "SQS:ReceiveMessage",
          "SQS:DeleteMessage",
          "SQS:GetQueueUrl"
        ],
        "Resource" : [
          "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:do-not-delete-rds-custom-*"
        ],
        "Effect" : "Allow",
        "Sid" : "SendMessageToSQSQueue"
      }
    ]
  })
}

resource "aws_iam_role" "rds_custom_role" {
  count              = var.rds_custom ? 1 : 0
  name               = "AWSRDSCustomSQLServerInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "custom_attach" {
  count      = var.rds_custom ? 1 : 0
  name       = "rds-custom-attachment"
  roles      = [element(aws_iam_role.rds_custom_role[*].name, 0)]
  policy_arn = element(aws_iam_policy.policy[*].arn, 0)

}

resource "aws_iam_instance_profile" "rds_custom_profile" {
  count = var.rds_custom ? 1 : 0
  name  = "AWSRDSCustomSQLServerInstanceProfile"
  role  = element(aws_iam_role.rds_custom_role[*].name, 0)

}

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
  count               = var.rds_sql ? 1 : 0
  name                = "${var.name}-monitoring-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}


resource "aws_db_option_group" "this" {
  count                    = var.enable_custom_option_group ? 1 : 0
  name                     = "${var.name}-option-group"
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
  name   = "${var.name}-paramater-group"
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

resource "aws_db_instance" "rds_sql_server" {

  count = var.rds_sql ? 1 : 0

  engine         = var.engine
  engine_version = var.engine_version
  port           = 1433

  identifier = var.instances_use_identifier_prefix ? null : var.name

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = false
  copy_tags_to_snapshot       = true
  apply_immediately           = var.apply_immediately

  custom_iam_instance_profile = var.rds_custom ? element(aws_iam_instance_profile.rds_custom_profile[*].name, 0) : null # Instance profile is required for Custom for SQL Server

  backup_window           = var.preferred_backup_window
  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.preferred_maintenance_window
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  db_subnet_group_name = local.db_subnet_group_name
  instance_class       = var.instance_class
  kms_key_id           = var.kms_key_id
  parameter_group_name = var.enable_custom_parameter_group ? aws_db_parameter_group.sql_server[0].name : var.db_parameter_group_name
  option_group_name    = var.enable_custom_option_group ? aws_db_option_group.this[0].name : null

  domain_ou              = var.ad_domain_ou
  domain_fqdn            = var.ad_domain_fqdn
  domain_dns_ips         = var.ad_domain_dns_ips
  domain_auth_secret_arn = var.ad_domain_auth_secret_arn

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  license_model         = "license-included"

  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.monitoring_role[0].arn
  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["error"]

  username                    = var.master_username
  manage_master_user_password = true

  multi_az               = var.multi_az # Custom RDS does support multi AZ
  vpc_security_group_ids = var.allowed_security_groups

  timeouts {
    create = "80m"
  }
  tags = var.tags

  depends_on = [aws_iam_policy_attachment.custom_attach]

}

resource "aws_db_instance" "rds_sql_server_read_replica" {

  count = var.read_replica ? 1 : 0

  engine         = var.engine
  engine_version = var.engine_version
  port           = 1433

  identifier = var.instances_use_identifier_prefix ? null : "${var.name}-read-replica"

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately


  maintenance_window  = var.preferred_maintenance_window
  deletion_protection = var.deletion_protection

  instance_class       = var.instance_class
  kms_key_id           = var.kms_key_id
  parameter_group_name = var.custom_db_paramater_group_name

  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  vpc_security_group_ids = compact(concat([try(aws_security_group.this[0].id, "")], var.vpc_security_group_ids))

  replicate_source_db = element(aws_db_instance.rds_sql_server[*].identifier, 0)

  timeouts {
    create = "80m"
  }

  tags       = var.tags
  depends_on = [aws_iam_policy_attachment.custom_attach]
}

# data "local_file" "sql_query" {
#   filename = var.ssrs_query_file
# }

# resource "null_resource" "execute_sql" {
#   depends_on = [aws_db_instance.rds_sql_server]

#   provisioner "local-exec" {
#     command = "sqlcmd -S ${aws_db_instance.rds_sql_server.address} -U ${aws_db_instance.rds_sql_server.username} -P ${aws_db_instance.rds_sql_server.password} -d your_database_name -i ${data.local_file.sql_query.filename}"
#   }
# }
