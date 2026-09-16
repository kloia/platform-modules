# AWS MSK Connect Terraform Module

Terraform module which creates Amazon MSK Connect resources: custom plugins,
worker configurations and connectors.

It wraps the three AWS provider resources:

- `aws_mskconnect_custom_plugin`
- `aws_mskconnect_worker_configuration`
- `aws_mskconnect_connector`

All three are optional and independently driven by maps, so the module can
register a single plugin, a worker configuration, and one or more connectors in
one call. Connector configuration changes force a connector replacement (see
[Notes](#notes)) to avoid silent configuration drift.

## Usage

### Couchbase CDC source connector (IAM → MSK)

The artifact key and plugin name are content-addressed: the `…a1b2c3d4…` suffix
is the SHA-256 of the plugin ZIP, recorded in the committed artifact manifest.

```hcl
module "msk_connect" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-msk-connect/v0.2.1"

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
      name        = "couchbase-source-worker"
      description = "Worker config: SSM config provider, string/byte converters"
      properties_file_content = <<-EOT
        key.converter=org.apache.kafka.connect.storage.StringConverter
        value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
        config.providers=ssm
        config.providers.ssm.class=com.amazonaws.kafka.config.providers.SsmParamStoreConfigProvider
        config.providers.ssm.param.region=eu-west-1
        offset.storage.replication.factor=3
        config.storage.replication.factor=3
        status.storage.replication.factor=3
      EOT
    }
  }

  connectors = {
    couchbase_source = {
      name                 = "couchbase-source"
      description          = "Couchbase CDC -> Kafka"
      kafkaconnect_version = "3.7.x"

      plugin_key               = "couchbase"
      worker_configuration_key = "couchbase"

      connector_configuration = {
        "connector.class"            = "com.couchbase.connect.kafka.CouchbaseSourceConnector"
        "couchbase.source.handler"   = "com.couchbase.connect.kafka.handler.source.RawJsonSourceHandler"
        "couchbase.bucket"           = "example-bucket"
        "couchbase.collections"      = "example.collection"
        "couchbase.topic"            = "example-bucket.example.collection"
        "couchbase.enable.tls"       = "true"
        "couchbase.seed.nodes"       = "cb.example.com"
        "couchbase.network"          = "external"
        "couchbase.username"         = "$${ssm::/msk-connect/couchbase/username}"
        "couchbase.password"         = "$${ssm::/msk-connect/couchbase/password}"
        "key.converter"              = "org.apache.kafka.connect.storage.StringConverter"
        "value.converter"            = "org.apache.kafka.connect.converters.ByteArrayConverter"
        "config.action.reload"       = "none"
        "tasks.max"                  = "1"
      }

      capacity = {
        provisioned_capacity = {
          mcu_count    = 1
          worker_count = 1
        }
      }

      kafka_cluster = {
        bootstrap_servers = module.msk.bootstrap_brokers_iam
        vpc = {
          security_groups = [module.msk_connect_sg.security_group_id]
          subnets         = module.queue_subnets.ids
        }
      }

      kafka_cluster_client_authentication = {
        authentication_type = "IAM"
      }

      kafka_cluster_encryption_in_transit = {
        encryption_type = "TLS"
      }

      service_execution_role_arn = aws_iam_role.msk_connect_execution.arn

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
```

> **Feature-branch ref (development only):** while the module is unreleased,
> use `//modules/aws-msk-connect` with a branch ref, e.g.
> `git::https://github.com/kloia/platform-modules.git//modules/aws-msk-connect?ref=<feature-branch>`.
> Once released, consume the immutable `module/aws-msk-connect/v<version>` tag
> (no `//` subdirectory).

### Module-managed service execution role (opt-in)

The same connector, but the module creates the MSK Connect service execution
role and injects its ARN, so the caller does not have to create the role out of
band. `connectors` then omits `service_execution_role_arn`.

```hcl
module "msk_connect" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-msk-connect/v0.2.1"

  execution_role = {
    create            = true
    name              = "msk-connect-couchbase-source-exec"
    description       = "MSK Connect service execution role for the Couchbase CDC source connector"
    connector_name    = "couchbase-source" # must match a connectors entry name
    cluster_arn       = "arn:aws:kafka:eu-west-1:123456789012:cluster/example-msk-cluster/300d0000-0000-0005-000f-00000000000b-1"
    target_topic_name = "example-bucket.example.collection"
    ssm_parameter_arns = [
      "arn:aws:ssm:eu-west-1:123456789012:parameter/msk-connect/couchbase/username",
      "arn:aws:ssm:eu-west-1:123456789012:parameter/msk-connect/couchbase/password",
    ]
    kms_key_arn       = "arn:aws:kms:eu-west-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    plugin_bucket_arn = "arn:aws:s3:::msk-connect-plugins"
  }

  custom_plugins        = { /* as above */ }
  worker_configurations = { /* as above */ }

  connectors = {
    couchbase_source = {
      name                 = "couchbase-source"
      kafkaconnect_version = "3.7.x"

      plugin_key               = "couchbase"
      worker_configuration_key = "couchbase"

      connector_configuration = { /* as above */ }

      capacity = {
        provisioned_capacity = {
          mcu_count    = 1
          worker_count = 1
        }
      }

      kafka_cluster = {
        bootstrap_servers = module.msk.bootstrap_brokers_iam
        vpc = {
          security_groups = [module.msk_connect_sg.security_group_id]
          subnets         = module.queue_subnets.ids
        }
      }

      kafka_cluster_client_authentication = {
        authentication_type = "IAM"
      }

      kafka_cluster_encryption_in_transit = {
        encryption_type = "TLS"
      }

      # service_execution_role_arn omitted: the module injects the ARN of the
      # role created above.

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
```

See [Service execution role](#service-execution-role-opt-in) for the trust and
permission policies this creates and the `connector_name` contract.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create` | Controls whether any MSK Connect resources are created | `bool` | `true` | no |
| `custom_plugins` | Map of custom plugins to register from S3 | `map(object)` | `{}` | no |
| `worker_configurations` | Map of worker configurations (connect-distributed.properties) | `map(object)` | `{}` | no |
| `connectors` | Map of connectors to create | `map(object)` | `{}` | no |
| `execution_role` | Opt-in creation of the MSK Connect service execution role and ARN injection into every connector (see [Notes](#service-execution-role-opt-in)) | `object` | `{}` | no |
| `tags` | Tags applied to all created resources (non-empty; see [Notes](#notes)) | `map(string)` | — | yes |

### `custom_plugins` object

| Key | Description | Type | Required |
|-----|-------------|------|----------|
| `name` | Plugin name (version/hash-derived, tied to the artifact manifest) | `string` | yes |
| `description` | Plugin description | `string` | no |
| `content_type` | `ZIP` or `JAR` | `string` | yes |
| `s3_bucket_arn` | ARN of the S3 bucket holding the artifact | `string` | yes |
| `s3_file_key` | S3 object key of the artifact (SHA-256 content-addressed) | `string` | yes |
| `s3_object_version` | S3 object version ID (exact immutable pin, NFR-3) | `string` | yes |
| `tags` | Per-plugin tags | `map(string)` | no |

### `worker_configurations` object

| Key | Description | Type | Required |
|-----|-------------|------|----------|
| `name` | Worker configuration name | `string` | yes |
| `description` | Worker configuration description | `string` | no |
| `properties_file_content` | Raw or base64 connect-distributed.properties content | `string` | yes |
| `tags` | Per-worker-configuration tags | `map(string)` | no |

### `connectors` object

| Key | Description | Type | Required |
|-----|-------------|------|----------|
| `name` | Connector name | `string` | yes |
| `description` | Connector description | `string` | no |
| `kafkaconnect_version` | Kafka Connect version, e.g. `3.7.x` | `string` | yes |
| `plugin_key` | Key into `custom_plugins` to attach | `string` | yes |
| `worker_configuration_key` | Key into `worker_configurations` to attach | `string` | no |
| `connector_configuration` | Connector-specific config map | `map(string)` | yes |
| `capacity` | Provisioned or autoscaling capacity (exactly one) | `object` | yes |
| `kafka_cluster` | Bootstrap servers + VPC (SGs, subnets) | `object` | yes |
| `kafka_cluster_client_authentication` | `IAM` or `NONE` | `object` | yes |
| `kafka_cluster_encryption_in_transit` | `TLS` or `PLAINTEXT` | `object` | yes |
| `service_execution_role_arn` | MSK Connect service execution role ARN. Required unless `execution_role.create=true`; when the module creates the role, its ARN overrides any value set here | `string` | no (conditional) |
| `log_delivery` | Worker log delivery (CloudWatch Logs / Firehose / S3) | `object` | no |
| `tags` | Per-connector tags | `map(string)` | no |

### `execution_role` object

| Key | Description | Type | Required |
|-----|-------------|------|----------|
| `create` | Create the role and inject its ARN into every connector | `bool` | no (default `false`) |
| `name` | IAM role name | `string` | yes when `create=true` |
| `description` | IAM role description | `string` | no |
| `connector_name` | Connector name the trust policy binds `aws:SourceArn` to; must match a `connectors` entry `name` | `string` | yes when `create=true` |
| `cluster_arn` | MSK cluster ARN; region, account, name and UUID are parsed out of it | `string` | yes when `create=true` |
| `target_topic_name` | Topic the connector produces to | `string` | yes when `create=true` |
| `ssm_parameter_arns` | SSM parameter ARNs the SSM config provider may read (non-empty) | `list(string)` | yes when `create=true` |
| `kms_key_arn` | KMS key encrypting those parameters | `string` | yes when `create=true` |
| `plugin_bucket_arn` | S3 bucket holding the custom plugin artifact | `string` | yes when `create=true` |

## Outputs

| Name | Description |
|------|-------------|
| `custom_plugins` | Map of created custom plugins (`arn`, `latest_revision`, `state`) keyed by input key |
| `worker_configurations` | Map of created worker configurations (`arn`, `latest_revision`) keyed by input key |
| `connectors` | Map of created connectors (`arn`, `version`) keyed by input key |
| `execution_role_arn` | ARN of the created service execution role, or `null` when `execution_role.create=false` |
| `execution_role_name` | Name of the created service execution role, or `null` when `execution_role.create=false` |

## Notes

- **No provider blocks** are declared; the provider configuration is inherited
  from the calling module. The module requires the AWS provider on the `~> 6.53`
  line; the consuming leaf holds an exact `6.53.0` lock covering all four
  platforms (Linux/Apple Silicon, amd64/arm64).
- **Connector configuration changes force replacement.** The module hashes
  `connector_configuration` into a `terraform_data` trigger and wires
  `replace_triggered_by` onto the connector, because AWS provider 6.x can
  report an in-place configuration update as successful while AWS keeps the
  old configuration (upstream issue #47004). A configuration diff therefore
  recreates the connector instead of risking permanent drift. Verify the live
  configuration with `aws kafkaconnect describe-connector` after any change.
- **Replacement resets offsets.** Recreating a connector yields a new
  `__amazon_msk_connect_offsets_*` topic, so the new connector backfills from
  the configured offset policy rather than resuming. For credential-only
  rotation keep the configuration identical (it holds only the `$${ssm::…}`
  placeholder) and rotate out-of-band via SSM + `RestartConnector` — that path
  does not change the configuration and does not trigger replacement.
- **Plugin and worker configuration are immutable once created** (their
  identifying attributes are `Forces new resource`). The exact `s3_object_version`
  is required, and the plugin name/key are content-addressed so a new artifact
  is a distinct plugin rather than an in-place change.
- **Tags are mandatory.** `tags` must be non-empty; the agreed cost-allocation
  key set (`Name`, `Project`, `Service`, `Criticality`, `Owner`, plus
  `Environment`) is enforced by the consuming unit's required-tag check, not by
  this generic module.
- The `$${ssm::…}` placeholders are escaped so Terraform passes the literal
  `${ssm::…}` string to MSK Connect; credentials are resolved by the SSM config
  provider at runtime and never stored in Terraform state, Git, or logs.

### Service execution role (opt-in)

`execution_role = { create = true, … }` makes the module create the MSK Connect
service execution role and inject its ARN into every connector, so consumers do
not have to create the role out of band.

**Trust policy.** MSK Connect must be able to assume the role, and the role must
not be assumable by a connector in another account (the confused-deputy
problem). The connector ARN contains a generated UUID that does not exist when
the role is created, so the trust policy binds `aws:SourceArn` to the
*predetermined connector name* instead:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "kafkaconnect.amazonaws.com" },
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": { "aws:SourceAccount": "<account id parsed from cluster_arn>" },
      "ArnLike": { "aws:SourceArn": "arn:aws:kafkaconnect:<region>:<account id>:connector/<connector_name>/*" }
    }
  }]
}
```

`execution_role.connector_name` must therefore equal the `name` of at least one
entry in `connectors`. A mismatch produces a role MSK Connect can never assume,
so the module fails at plan time instead of at connector creation. This contract
is enforced by an IAM-role lifecycle precondition, which is compatible with the
module's Terraform 1.5.7 minimum version.

**Permission policy.** The AWS reference policy for an IAM-auth cluster, plus
the reads the SSM config provider and the custom plugin artifact need. Topic and
group ARNs are derived from `execution_role.cluster_arn`
(`arn:aws:kafka:<region>:<account id>:cluster/<name>/<uuid>`), so they cannot
drift apart from the cluster the connector actually targets:

| Actions | Resource |
|---------|----------|
| `kafka-cluster:Connect`, `kafka-cluster:DescribeCluster` | `cluster_arn` |
| `kafka-cluster:CreateTopic`, `kafka-cluster:WriteData`, `kafka-cluster:ReadData`, `kafka-cluster:DescribeTopic` | `<topic-base>/__amazon_msk_connect_*` |
| `kafka-cluster:CreateTopic`, `kafka-cluster:WriteData`, `kafka-cluster:DescribeTopic` | `<topic-base>/<target_topic_name>` (source connectors produce to it; `CreateTopic` lets the connector create that one topic when it does not exist) |
| `kafka-cluster:AlterGroup`, `kafka-cluster:DescribeGroup` | `<group-base>/__amazon_msk_connect_*` and `<group-base>/connect-*` |
| `ssm:GetParameter` | exactly `ssm_parameter_arns` |
| `kms:Decrypt` | exactly `kms_key_arn` |
| `s3:ListBucket` | `plugin_bucket_arn` |
| `s3:GetObject` | `plugin_bucket_arn/*` (MSK Connect downloads the plugin artifact at connector creation, restart and failover) |

The role gets **no CloudWatch Logs permissions**. Worker log delivery is a
vended log delivered by `delivery.logs.amazonaws.com` through the destination
log group's resource policy and does not use the execution role.

With `create = true` every `connectors` entry is given the created role's ARN,
overriding any per-connector `service_execution_role_arn`. With `create = false`
(the default) the caller's ARN is passed through unchanged, exactly as in
0.1.0.
