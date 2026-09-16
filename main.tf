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

  service_execution_role_arn = each.value.service_execution_role_arn

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
  }
}
