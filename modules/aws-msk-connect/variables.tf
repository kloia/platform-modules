variable "create" {
  description = "Controls whether any MSK Connect resources are created."
  type        = bool
  default     = true
}

################################################################################
# Custom Plugin
################################################################################

variable "custom_plugins" {
  description = "Map of MSK Connect custom plugins to create. Each entry registers a connector plugin artifact already stored in S3 (content-addressed, version-pinned)."
  type = map(object({
    name              = string
    description       = optional(string)
    content_type      = string
    s3_bucket_arn     = string
    s3_file_key       = string
    s3_object_version = string
    tags              = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for plugin in var.custom_plugins : contains(["ZIP", "JAR"], plugin.content_type)
    ])
    error_message = "custom_plugins[*].content_type must be one of \"ZIP\" or \"JAR\"."
  }

  validation {
    condition = alltrue([
      for plugin in var.custom_plugins : plugin.s3_object_version != ""
    ])
    error_message = "custom_plugins[*].s3_object_version must be a non-empty string; exact object-version pinning is required (NFR-3)."
  }
}

################################################################################
# Worker Configuration
################################################################################

variable "worker_configurations" {
  description = "Map of MSK Connect worker configurations to create. Each entry is the connect-distributed.properties file content (raw or base64)."
  type = map(object({
    name                    = string
    description             = optional(string)
    properties_file_content = string
    tags                    = optional(map(string))
  }))
  default = {}
}

################################################################################
# Connector
################################################################################

variable "connectors" {
  description = "Map of MSK Connect connectors to create. Each connector references a custom plugin (and optionally a worker configuration) by the key used in the corresponding map."
  type = map(object({
    name                 = string
    description          = optional(string)
    kafkaconnect_version = string

    plugin_key               = string
    worker_configuration_key = optional(string)

    connector_configuration = map(string)

    capacity = object({
      provisioned_capacity = optional(object({
        mcu_count    = optional(number)
        worker_count = number
      }))
      autoscaling = optional(object({
        mcu_count        = optional(number)
        min_worker_count = number
        max_worker_count = number
        scale_in_policy = optional(object({
          cpu_utilization_percentage = number
        }))
        scale_out_policy = optional(object({
          cpu_utilization_percentage = number
        }))
      }))
    })

    kafka_cluster = object({
      bootstrap_servers = string
      vpc = object({
        security_groups = list(string)
        subnets         = list(string)
      })
    })

    kafka_cluster_client_authentication = object({
      authentication_type = string
    })

    kafka_cluster_encryption_in_transit = object({
      encryption_type = string
    })

    service_execution_role_arn = string

    log_delivery = optional(object({
      worker_log_delivery = object({
        cloudwatch_logs = optional(object({
          enabled   = bool
          log_group = string
        }))
        firehose = optional(object({
          enabled         = bool
          delivery_stream = optional(string)
        }))
        s3 = optional(object({
          enabled = bool
          bucket  = optional(string)
          prefix  = optional(string)
        }))
      })
    }))

    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for connector in var.connectors :
      (try(connector.capacity.provisioned_capacity, null) != null) != (try(connector.capacity.autoscaling, null) != null)
    ])
    error_message = "connectors[*].capacity must define exactly one of provisioned_capacity or autoscaling."
  }

  validation {
    condition = alltrue([
      for connector in var.connectors :
      contains(["IAM", "NONE"], connector.kafka_cluster_client_authentication.authentication_type)
    ])
    error_message = "connectors[*].kafka_cluster_client_authentication.authentication_type must be one of \"IAM\" or \"NONE\"."
  }

  validation {
    condition = alltrue([
      for connector in var.connectors :
      contains(["TLS", "PLAINTEXT"], connector.kafka_cluster_encryption_in_transit.encryption_type)
    ])
    error_message = "connectors[*].kafka_cluster_encryption_in_transit.encryption_type must be one of \"TLS\" or \"PLAINTEXT\"."
  }
}

################################################################################
# Common
################################################################################

variable "tags" {
  description = "Map of tags applied to all resources created by this module. Must be non-empty; the agreed cost-allocation key set is enforced by the consuming unit's required-tag check. Per-resource tags are merged on top."
  type        = map(string)

  validation {
    condition     = length(var.tags) > 0
    error_message = "At least one tag is required; the mandatory cost-allocation key set is enforced by the consuming unit's required-tag check."
  }
}
