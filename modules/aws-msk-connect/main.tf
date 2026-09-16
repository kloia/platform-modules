################################################################################
# MSK Connect Custom Plugin
################################################################################

resource "aws_mskconnect_custom_plugin" "this" {
  for_each = { for name, plugin in var.custom_plugins : name => plugin if var.create }

  name         = each.value.name
  description  = each.value.description
  content_type = each.value.content_type

  location {
    s3 {
      bucket_arn     = each.value.s3_bucket_arn
      file_key       = each.value.s3_file_key
      object_version = each.value.s3_object_version
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# MSK Connect Worker Configuration
################################################################################

resource "aws_mskconnect_worker_configuration" "this" {
  for_each = { for name, wc in var.worker_configurations : name => wc if var.create }

  name                    = each.value.name
  description             = each.value.description
  properties_file_content = each.value.properties_file_content

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# Service execution role (opt-in)
#
# MSK Connect requires a service execution role that MSK Connect itself assumes
# (the service-linked role is not accepted). The confused-deputy conditions on
# its trust policy need the connector ARN, which does not exist yet when the
# role is created, so the trust policy binds the predetermined connector name
# instead. See
# https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-service-execution-role.html
################################################################################

locals {
  create_execution_role = var.create && var.execution_role.create

  # Parse the cluster ARN once so the trust policy and the IAM-auth permission
  # policy cannot drift apart:
  # arn:aws:kafka:<region>:<account>:cluster/<name>/<uuid>
  execution_role_cluster_arn = try(
    regex(
      "^arn:aws:kafka:(?P<region>[^:]+):(?P<account_id>[0-9]{12}):cluster/(?P<name>[^/]+)/(?P<uuid>.+)$",
      var.execution_role.cluster_arn
    ),
    null
  )

  execution_role_region     = try(local.execution_role_cluster_arn["region"], null)
  execution_role_account_id = try(local.execution_role_cluster_arn["account_id"], null)
  execution_role_topic_base = local.execution_role_cluster_arn == null ? null : format(
    "arn:aws:kafka:%s:%s:topic/%s/%s",
    local.execution_role_region,
    local.execution_role_account_id,
    local.execution_role_cluster_arn["name"],
    local.execution_role_cluster_arn["uuid"],
  )
  execution_role_group_base = local.execution_role_cluster_arn == null ? null : format(
    "arn:aws:kafka:%s:%s:group/%s/%s",
    local.execution_role_region,
    local.execution_role_account_id,
    local.execution_role_cluster_arn["name"],
    local.execution_role_cluster_arn["uuid"],
  )
}

data "aws_iam_policy_document" "execution_role_assume" {
  count = local.create_execution_role ? 1 : 0

  statement {
    sid     = "MskConnectAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kafkaconnect.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.execution_role_account_id]
    }

    # The connector ARN embeds a generated UUID that is unknown until the
    # connector is created, so bind on the predetermined connector name.
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:kafkaconnect:${local.execution_role_region}:${local.execution_role_account_id}:connector/${var.execution_role.connector_name}/*",
      ]
    }
  }
}

# AWS reference policy for an IAM-auth cluster, plus the SSM/KMS reads the SSM
# config provider needs and the S3 reads MSK Connect performs for the custom
# plugin artifact at connector creation, restart and failover.
#
# No CloudWatch Logs permissions: worker log delivery is a vended log delivered
# by delivery.logs.amazonaws.com through the destination log group's resource
# policy, and does not use the execution role.
data "aws_iam_policy_document" "execution_role" {
  count = local.create_execution_role ? 1 : 0

  statement {
    sid       = "ClusterConnect"
    effect    = "Allow"
    actions   = ["kafka-cluster:Connect", "kafka-cluster:DescribeCluster"]
    resources = [var.execution_role.cluster_arn]
  }

  statement {
    sid       = "InternalTopics"
    effect    = "Allow"
    actions   = ["kafka-cluster:CreateTopic", "kafka-cluster:WriteData", "kafka-cluster:ReadData", "kafka-cluster:DescribeTopic"]
    resources = ["${local.execution_role_topic_base}/__amazon_msk_connect_*"]
  }

  # Source connectors only produce to the target topic.
  statement {
    sid       = "TargetTopic"
    effect    = "Allow"
    actions   = ["kafka-cluster:WriteData", "kafka-cluster:DescribeTopic"]
    resources = ["${local.execution_role_topic_base}/${var.execution_role.target_topic_name}"]
  }

  statement {
    sid     = "ConsumerGroups"
    effect  = "Allow"
    actions = ["kafka-cluster:AlterGroup", "kafka-cluster:DescribeGroup"]
    resources = [
      "${local.execution_role_group_base}/__amazon_msk_connect_*",
      "${local.execution_role_group_base}/connect-*",
    ]
  }

  statement {
    sid       = "SsmConfigProvider"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = var.execution_role.ssm_parameter_arns
  }

  statement {
    sid       = "SsmParameterDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.execution_role.kms_key_arn]
  }

  statement {
    sid       = "PluginArtifactListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.execution_role.plugin_bucket_arn]
  }

  statement {
    sid       = "PluginArtifactGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.execution_role.plugin_bucket_arn}/*"]
  }
}

resource "aws_iam_role" "execution_role" {
  count = local.create_execution_role ? 1 : 0

  name        = var.execution_role.name
  description = var.execution_role.description

  assume_role_policy = data.aws_iam_policy_document.execution_role_assume[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "execution_role" {
  count = local.create_execution_role ? 1 : 0

  name   = "${var.execution_role.name}-policy"
  role   = aws_iam_role.execution_role[0].id
  policy = data.aws_iam_policy_document.execution_role[0].json
}

################################################################################
# Connector configuration drift guard
#
# aws provider 6.x can report an in-place connector_configuration update as
# successful while AWS keeps the old configuration (upstream issue #47004).
# Hash the configuration into a terraform_data trigger and force connector
# replacement whenever it changes, so a config diff cannot silently leave the
# live connector permanently drifted.
################################################################################

resource "terraform_data" "connector_configuration" {
  for_each = { for name, connector in var.connectors : name => connector if var.create }

  triggers_replace = {
    config_sha256 = sha256(jsonencode(each.value.connector_configuration))
  }
}

################################################################################
# MSK Connect Connector
################################################################################

resource "aws_mskconnect_connector" "this" {
  for_each = { for name, connector in var.connectors : name => connector if var.create }

  name                 = each.value.name
  description          = each.value.description
  kafkaconnect_version = each.value.kafkaconnect_version

  connector_configuration = each.value.connector_configuration

  capacity {
    dynamic "provisioned_capacity" {
      for_each = try(each.value.capacity.provisioned_capacity, null) != null ? [each.value.capacity.provisioned_capacity] : []
      content {
        mcu_count    = provisioned_capacity.value.mcu_count
        worker_count = provisioned_capacity.value.worker_count
      }
    }

    dynamic "autoscaling" {
      for_each = try(each.value.capacity.autoscaling, null) != null ? [each.value.capacity.autoscaling] : []
      content {
        mcu_count        = autoscaling.value.mcu_count
        min_worker_count = autoscaling.value.min_worker_count
        max_worker_count = autoscaling.value.max_worker_count

        dynamic "scale_in_policy" {
          for_each = try(autoscaling.value.scale_in_policy, null) != null ? [autoscaling.value.scale_in_policy] : []
          content {
            cpu_utilization_percentage = scale_in_policy.value.cpu_utilization_percentage
          }
        }

        dynamic "scale_out_policy" {
          for_each = try(autoscaling.value.scale_out_policy, null) != null ? [autoscaling.value.scale_out_policy] : []
          content {
            cpu_utilization_percentage = scale_out_policy.value.cpu_utilization_percentage
          }
        }
      }
    }
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = each.value.kafka_cluster.bootstrap_servers

      vpc {
        security_groups = each.value.kafka_cluster.vpc.security_groups
        subnets         = each.value.kafka_cluster.vpc.subnets
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = each.value.kafka_cluster_client_authentication.authentication_type
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = each.value.kafka_cluster_encryption_in_transit.encryption_type
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.this[each.value.plugin_key].arn
      revision = aws_mskconnect_custom_plugin.this[each.value.plugin_key].latest_revision
    }
  }

  dynamic "worker_configuration" {
    for_each = each.value.worker_configuration_key != null ? [each.value.worker_configuration_key] : []
    content {
      arn      = aws_mskconnect_worker_configuration.this[worker_configuration.value].arn
      revision = aws_mskconnect_worker_configuration.this[worker_configuration.value].latest_revision
    }
  }

  # When the module owns the execution role, every connector gets its ARN
  # (overriding any per-connector value). Otherwise the caller's value is
  # passed through unchanged, as in 0.1.0.
  service_execution_role_arn = local.create_execution_role ? aws_iam_role.execution_role[0].arn : each.value.service_execution_role_arn

  dynamic "log_delivery" {
    for_each = try(each.value.log_delivery, null) != null ? [each.value.log_delivery] : []
    content {
      worker_log_delivery {
        dynamic "cloudwatch_logs" {
          for_each = try(log_delivery.value.worker_log_delivery.cloudwatch_logs, null) != null ? [log_delivery.value.worker_log_delivery.cloudwatch_logs] : []
          content {
            enabled   = cloudwatch_logs.value.enabled
            log_group = cloudwatch_logs.value.log_group
          }
        }

        dynamic "firehose" {
          for_each = try(log_delivery.value.worker_log_delivery.firehose, null) != null ? [log_delivery.value.worker_log_delivery.firehose] : []
          content {
            enabled         = firehose.value.enabled
            delivery_stream = firehose.value.delivery_stream
          }
        }

        dynamic "s3" {
          for_each = try(log_delivery.value.worker_log_delivery.s3, null) != null ? [log_delivery.value.worker_log_delivery.s3] : []
          content {
            enabled = s3.value.enabled
            bucket  = s3.value.bucket
            prefix  = s3.value.prefix
          }
        }
      }
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  lifecycle {
    replace_triggered_by = [
      terraform_data.connector_configuration[each.key]
    ]

    # Preserves 0.1.0 behaviour: unless the module creates the execution role,
    # every connector must carry a caller-supplied ARN. Fail at plan time with
    # an actionable message instead of letting AWS reject the connector.
    precondition {
      condition     = local.create_execution_role || each.value.service_execution_role_arn != null
      error_message = "connectors[${each.key}].service_execution_role_arn is required unless execution_role.create=true (the module then injects the role it creates)."
    }
  }
}
