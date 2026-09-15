# Offline plan fixture for the aws-msk-connect module.
#
# This is NOT a deployable stack. It exercises every resource type and the
# module validation blocks so the wiring can be verified with `terraform plan`
# without AWS credentials or a live cluster. The provider flags below skip
# credential/account discovery only so planning works offline.

provider "aws" {
  region                      = "eu-west-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "msk_connect" {
  source = "../.."

  custom_plugins = {
    couchbase = {
      name              = "couchbase-kafka-source-4.1.14-a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"
      description       = "Couchbase Kafka source connector 4.1.14 + AWS config-provider bundle"
      content_type      = "ZIP"
      s3_bucket_arn     = "arn:aws:s3:::msk-connect-plugins"
      s3_file_key       = "couchbase-kafka-connect-4.1.14-aws-provider-a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2.zip"
      s3_object_version = "fC5V0Y7f3j0KxQ9a1BmD2NpL"
    }
  }

  worker_configurations = {
    couchbase = {
      name                    = "couchbase-source-worker"
      properties_file_content = "key.converter=org.apache.kafka.connect.storage.StringConverter\nvalue.converter=org.apache.kafka.connect.converters.ByteArrayConverter\nconfig.providers=ssm\nconfig.providers.ssm.class=com.amazonaws.kafka.config.providers.SsmParamStoreConfigProvider\nconfig.providers.ssm.param.region=eu-west-1\noffset.storage.replication.factor=3\nconfig.storage.replication.factor=3\nstatus.storage.replication.factor=3\n"
    }
  }

  connectors = {
    couchbase_source = {
      name                     = "couchbase-source"
      kafkaconnect_version     = "3.7.x"
      plugin_key               = "couchbase"
      worker_configuration_key = "couchbase"

      connector_configuration = {
        "connector.class"          = "com.couchbase.connect.kafka.CouchbaseSourceConnector"
        "couchbase.source.handler" = "com.couchbase.connect.kafka.handler.source.RawJsonSourceHandler"
        "couchbase.bucket"         = "example-bucket"
        "couchbase.collections"    = "example.collection"
        "couchbase.topic"          = "example-bucket.example.collection"
        "couchbase.enable.tls"     = "true"
        "couchbase.seed.nodes"     = "cb.example.com"
        "couchbase.network"        = "external"
        "couchbase.username"       = "$${ssm::/msk-connect/couchbase/username}"
        "couchbase.password"       = "$${ssm::/msk-connect/couchbase/password}"
        "key.converter"            = "org.apache.kafka.connect.storage.StringConverter"
        "value.converter"          = "org.apache.kafka.connect.converters.ByteArrayConverter"
        "config.action.reload"     = "none"
        "tasks.max"                = "1"
      }

      capacity = {
        provisioned_capacity = {
          mcu_count    = 1
          worker_count = 1
        }
      }

      kafka_cluster = {
        bootstrap_servers = "b-1.cluster.abc123.kafka.eu-west-1.amazonaws.com:9098"
        vpc = {
          security_groups = ["sg-0123456789abcdef0"]
          subnets         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
        }
      }

      kafka_cluster_client_authentication = {
        authentication_type = "IAM"
      }

      kafka_cluster_encryption_in_transit = {
        encryption_type = "TLS"
      }

      service_execution_role_arn = "arn:aws:iam::123456789012:role/msk-connect-exec"

      log_delivery = {
        worker_log_delivery = {
          cloudwatch_logs = {
            enabled   = true
            log_group = "/aws/msk-connect/couchbase"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
