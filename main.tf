locals {
  enabled = var.enabled

  brokers = local.enabled ? flatten(data.aws_msk_broker_nodes.default[0].node_info_list.*.endpoints) : []
  # If var.storage_autoscaling_max_capacity is not set, don't autoscale past current size
  broker_volume_size_max = coalesce(var.storage_autoscaling_max_capacity, var.broker_volume_size)

  # var.client_broker types
  plaintext     = "PLAINTEXT"
  tls_plaintext = "TLS_PLAINTEXT"
  tls           = "TLS"

  # The following ports are not configurable. See: https://docs.aws.amazon.com/msk/latest/developerguide/client-access.html#port-info
  protocols = {
    plaintext = {
      name = "plaintext"
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#bootstrap_brokers
      enabled = contains([local.plaintext, local.tls_plaintext], var.client_broker)
      port    = 9092
    }
    tls = {
      name = "TLS"
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#bootstrap_brokers_tls
      enabled = contains([local.tls_plaintext, local.tls], var.client_broker)
      port    = 9094
    }
    sasl_scram = {
      name = "SASL/SCRAM"
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#bootstrap_brokers_sasl_scram
      enabled = var.client_sasl_scram_enabled && contains([local.tls_plaintext, local.tls], var.client_broker)
      port    = 9096
    }
    sasl_iam = {
      name = "SASL/IAM"
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#bootstrap_brokers_sasl_iam
      enabled = var.client_sasl_iam_enabled && contains([local.tls_plaintext, local.tls], var.client_broker)
      port    = 9098
    }
    # The following two protocols are always enabled.
    # See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#zookeeper_connect_string
    # and https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#zookeeper_connect_string_tls
    zookeeper_plaintext = {
      name    = "Zookeeper plaintext"
      enabled = true
      port    = 2181
    }
    zookeeper_tls = {
      name    = "Zookeeper TLS"
      enabled = true
      port    = 2182
    }
    # The following two protocols are enabled on demand of user
    # See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#jmx_exporter
    # and https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#node_exporter
    # and https://docs.aws.amazon.com/msk/latest/developerguide/open-monitoring.html#set-up-prometheus-host
    jmx_exporter = {
      name    = "JMX Exporter"
      enabled = var.jmx_exporter_enabled
      port    = 11001
    }
    node_exporter = {
      name    = "Node Exporter"
      enabled = var.node_exporter_enabled
      port    = 11002
    }

  }

  credential = var.client_sasl_scram_enabled ? jsonencode({
    username = "msk"
    password = random_password.password[0].result
  }) : null
}

data "aws_msk_broker_nodes" "default" {
  count = local.enabled ? 1 : 0

  cluster_arn = join("", aws_msk_cluster.default.*.arn)
}

data "aws_subnets" "private_subnets_with_queue_tag" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_id_names}"]
  }
}

resource "random_password" "password" {
  count   = local.enabled && var.client_sasl_scram_enabled ? 1 : 0
  length  = 10
  special = false
}


resource "aws_secretsmanager_secret" "sm" {
  count                   = local.enabled && var.client_sasl_scram_enabled ? 1 : 0
  name                    = var.secret_name
  description             = "MSK sasl scram auth secret"
  recovery_window_in_days = 30
  kms_key_id              = var.encryption_at_rest_kms_key_arn
  depends_on              = [random_password.password[0]]
}

resource "aws_secretsmanager_secret_version" "sm-sv" {
  count         = local.enabled && var.client_sasl_scram_enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.sm[0].arn
  secret_string = local.credential
}

data "aws_iam_policy_document" "sm-policy" {
  count = local.enabled && var.client_sasl_scram_enabled ? 1 : 0
  statement {
    sid    = "AWSKafkaResourcePolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }

    actions   = ["secretsmanager:getSecretValue"]
    resources = [aws_secretsmanager_secret.sm[0].arn]
  }
}

resource "aws_secretsmanager_secret_policy" "policy" {
  count      = local.enabled && var.client_sasl_scram_enabled ? 1 : 0
  secret_arn = aws_secretsmanager_secret.sm[0].arn
  policy     = data.aws_iam_policy_document.sm-policy[0].json
}

resource "aws_msk_configuration" "config" {
  count          = local.enabled ? 1 : 0
  kafka_versions = [var.kafka_version]
  name           = var.name
  description    = "Manages an Amazon Managed Streaming for Kafka configuration"

  server_properties = join("\n", [for k in keys(var.properties) : format("%s = %s", k, var.properties[k])])
}

resource "aws_msk_cluster" "default" {
  #bridgecrew:skip=BC_AWS_LOGGING_18:Skipping `Amazon MSK cluster logging is not enabled` check since it can be enabled with cloudwatch_logs_enabled = true
  #bridgecrew:skip=BC_AWS_LOGGING_18:Skipping `Amazon MSK cluster logging is not enabled` check since it can be enabled with cloudwatch_logs_enabled = true
  #bridgecrew:skip=BC_AWS_GENERAL_32:Skipping `MSK cluster encryption at rest and in transit is not enabled` check since it can be enabled with encryption_in_cluster = true
  count                  = local.enabled ? 1 : 0
  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.broker_per_zone * length(length(try(data.aws_subnets.private_subnets_with_queue_tag.ids, null)) == 0 ? var.subnet_ids : try(data.aws_subnets.private_subnets_with_queue_tag.ids, null))
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    instance_type = var.broker_instance_type
    #ebs_volume_size = var.broker_volume_size
    client_subnets  = length(data.aws_subnets.private_subnets_with_queue_tag.ids) == 0 ? var.subnet_ids : try(data.aws_subnets.private_subnets_with_queue_tag.ids, null)
    security_groups = [var.associated_security_group_ids]
    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size
      }
    }
    connectivity_info {
      public_access {
        type = var.public_access_enabled ? "SERVICE_PROVIDED_EIPS" : "DISABLED"
      }
    }
  }
  configuration_info {
    arn      = aws_msk_configuration.config[0].arn
    revision = aws_msk_configuration.config[0].latest_revision
  }

  encryption_info {
    encryption_in_transit {
      client_broker = var.client_broker
      in_cluster    = var.encryption_in_cluster
    }
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn
  }

  dynamic "client_authentication" {
    for_each = var.client_tls_auth_enabled || var.client_sasl_scram_enabled || var.client_sasl_iam_enabled ? [1] : []
    content {
      dynamic "tls" {
        for_each = var.client_tls_auth_enabled ? [1] : []
        content {
          certificate_authority_arns = var.certificate_authority_arns
        }
      }
      dynamic "sasl" {
        for_each = var.client_sasl_scram_enabled || var.client_sasl_iam_enabled ? [1] : []
        content {
          scram = var.client_sasl_scram_enabled
          iam   = var.client_sasl_iam_enabled
        }
      }
      unauthenticated = var.client_allow_unauthenticated
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.node_exporter_enabled
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.cloudwatch_logs_enabled
        log_group = var.cloudwatch_logs_log_group
      }
      firehose {
        enabled         = var.firehose_logs_enabled
        delivery_stream = var.firehose_delivery_stream
      }
      s3 {
        enabled = var.s3_logs_enabled
        bucket  = var.s3_logs_bucket
        prefix  = var.s3_logs_prefix
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to ebs_volume_size in favor of autoscaling policy
      broker_node_group_info[0].storage_info[0].ebs_storage_info[0].volume_size,
    ]
  }

  tags = var.tags
}

resource "aws_msk_scram_secret_association" "default" {
  count = local.enabled && var.client_sasl_scram_enabled ? 1 : 0

  cluster_arn     = aws_msk_cluster.default[0].arn
  secret_arn_list = [aws_secretsmanager_secret.sm[0].arn]
}

resource "aws_appautoscaling_target" "default" {
  count = local.enabled && var.autoscaling_enabled ? 1 : 0

  max_capacity       = local.broker_volume_size_max
  min_capacity       = 1
  resource_id        = aws_msk_cluster.default[0].arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  service_namespace  = "kafka"
}

resource "aws_appautoscaling_policy" "default" {
  count = local.enabled && var.autoscaling_enabled ? 1 : 0

  name               = "${aws_msk_cluster.default[0].cluster_name}-broker-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_msk_cluster.default[0].arn
  scalable_dimension = join("", aws_appautoscaling_target.default.*.scalable_dimension)
  service_namespace  = join("", aws_appautoscaling_target.default.*.service_namespace)

  target_tracking_scaling_policy_configuration {
    disable_scale_in = var.storage_autoscaling_disable_scale_in
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    target_value = var.storage_autoscaling_target_value
  }
}
