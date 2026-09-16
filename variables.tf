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

    # Required unless execution_role.create=true, in which case the module
    # injects the ARN of the role it creates and ignores any value set here.
    service_execution_role_arn = optional(string)

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

  # The guard that every connector carries a role ARN when this module does not
  # create one lives as a lifecycle precondition on aws_mskconnect_connector:
  # referencing var.execution_role here and var.connectors from that variable's
  # validation would form a dependency cycle between the two validation rules.
}

################################################################################
# Service execution role (opt-in)
################################################################################

variable "execution_role" {
  description = "Opt-in: create the MSK Connect service execution role and inject its ARN into every connector. When create=false (default), every connectors entry must supply its own service_execution_role_arn, as in 0.1.0."
  type = object({
    create             = optional(bool, false)
    name               = optional(string)
    description        = optional(string)
    connector_name     = optional(string)       # binds the trust policy; must match a connectors entry name
    cluster_arn        = optional(string)       # MSK cluster ARN; region/account/name/uuid derived from it
    target_topic_name  = optional(string)       # topic the connector produces to
    ssm_parameter_arns = optional(list(string)) # credential parameters for the SSM config provider
    kms_key_arn        = optional(string)       # key encrypting those parameters
    plugin_bucket_arn  = optional(string)       # bucket holding the custom plugin artifact
  })
  default = {}

  validation {
    condition = !var.execution_role.create || alltrue([
      var.execution_role.name != null,
      var.execution_role.connector_name != null,
      var.execution_role.cluster_arn != null,
      var.execution_role.target_topic_name != null,
      var.execution_role.ssm_parameter_arns != null,
      var.execution_role.kms_key_arn != null,
      var.execution_role.plugin_bucket_arn != null,
    ])
    error_message = "execution_role.create=true requires name, connector_name, cluster_arn, target_topic_name, ssm_parameter_arns, kms_key_arn and plugin_bucket_arn."
  }

  validation {
    condition     = !var.execution_role.create || length(coalesce(var.execution_role.ssm_parameter_arns, [])) > 0
    error_message = "execution_role.ssm_parameter_arns must list at least one SSM parameter ARN when execution_role.create=true; an empty list would grant ssm:GetParameter on no resource while still requiring the statement."
  }

  validation {
    condition     = !var.execution_role.create || can(regex("^arn:aws:kafka:[^:]+:[0-9]{12}:cluster/[^/]+/.+$", var.execution_role.cluster_arn))
    error_message = "execution_role.cluster_arn must be an MSK cluster ARN of the form arn:aws:kafka:<region>:<account-id>:cluster/<name>/<uuid>."
  }

  # The connector-name cross-check is a lifecycle precondition on the managed
  # role. Terraform 1.5 permits preconditions to reference multiple inputs,
  # whereas variable validation may only reference its own variable until 1.9.
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
