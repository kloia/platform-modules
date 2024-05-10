# https://github.com/terraform-providers/terraform-provider-aws/issues/5218
# resource "aws_iam_service_linked_role" "default" {
#   count            = var.enabled && var.create_iam_service_linked_role ? 1 : 0
#   aws_service_name = "es.amazonaws.com"
#   description      = "AWSServiceRoleForAmazonElasticsearchService Service-Linked Role"
#   custom_suffix    = "OpenSearchLogging"
# }

# Role that pods can assume for access to elasticsearch and kibana
resource "aws_iam_role" "elasticsearch_user" {
  count              = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  name               = "${var.domain_name}-es-user-role"
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  description        = "IAM Role to assume to access the Elasticsearch ${var.domain_name} cluster"
  tags               = var.tags

  max_session_duration = var.iam_role_max_session_duration

  permissions_boundary = var.iam_role_permissions_boundary
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = var.aws_ec2_service_name
    }

    principals {
      type        = "AWS"
      identifiers = compact(concat(var.iam_authorizing_role_arns, var.iam_role_arns))
    }

    effect = "Allow"
  }
}

resource "aws_elasticsearch_domain" "default" {
  count                 = var.enabled ? 1 : 0
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  advanced_options = var.advanced_options

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    internal_user_database_enabled = var.advanced_security_options_internal_user_database_enabled
    master_user_options {
      master_user_arn      = var.advanced_security_options_master_user_arn
      master_user_name     = var.advanced_security_options_master_user_name
      master_user_password = var.advanced_security_options_master_user_password
    }
  }



  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_iops
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest_enabled
    kms_key_id = var.encrypt_at_rest_kms_key_id
  }


  domain_endpoint_options {
    enforce_https                   = var.domain_endpoint_options_enforce_https
    tls_security_policy             = var.domain_endpoint_options_tls_security_policy
    custom_endpoint_enabled         = var.custom_endpoint_enabled
    custom_endpoint                 = var.custom_endpoint_enabled ? var.custom_endpoint : null
    custom_endpoint_certificate_arn = var.custom_endpoint_enabled ? var.custom_endpoint_certificate_arn : null
  }

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    zone_awareness_enabled   = var.zone_awareness_enabled
    warm_enabled             = var.warm_enabled
    warm_count               = var.warm_enabled ? var.warm_count : null
    warm_type                = var.warm_enabled ? var.warm_type : null

    dynamic "zone_awareness_config" {
      for_each = var.availability_zone_count > 1 && var.zone_awareness_enabled ? [true] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  dynamic "vpc_options" {
    for_each = var.vpc_enabled ? [true] : []

    content {
      security_group_ids = var.security_groups
      subnet_ids         = var.subnet_ids
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  dynamic "cognito_options" {
    for_each = var.cognito_authentication_enabled ? [true] : []
    content {
      enabled          = true
      user_pool_id     = var.cognito_user_pool_id
      identity_pool_id = var.cognito_identity_pool_id
      role_arn         = var.cognito_iam_role_arn
    }
  }


  log_publishing_options {
    enabled                  = var.log_publishing_index_enabled
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = var.log_publishing_index_cloudwatch_log_group_arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_search_enabled
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = var.log_publishing_search_cloudwatch_log_group_arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_audit_enabled
    log_type                 = "AUDIT_LOGS"
    cloudwatch_log_group_arn = var.log_publishing_audit_cloudwatch_log_group_arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_application_enabled
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = var.log_publishing_application_cloudwatch_log_group_arn
  }



  tags = var.tags

  # depends_on = [aws_iam_service_linked_role.default]
}




data "aws_iam_policy_document" "default" {
  count = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0

  statement {
    effect = "Allow"

    actions = distinct(compact(var.iam_actions))

    resources = [
      join("", aws_elasticsearch_domain.default.*.arn),
      "${join("", aws_elasticsearch_domain.default.*.arn)}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = distinct(compact(concat(var.iam_role_arns, aws_iam_role.elasticsearch_user.*.arn)))
    }
  }

  # This statement is for non VPC ES to allow anonymous access from whitelisted IP ranges without requests signing
  # https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html#es-ac-types-ip
  # https://aws.amazon.com/premiumsupport/knowledge-center/anonymous-not-authorized-elasticsearch/
  dynamic "statement" {
    for_each = length(var.allowed_cidr_blocks) > 0 && !var.vpc_enabled ? [true] : []
    content {
      effect = "Allow"

      actions = distinct(compact(var.iam_actions))

      resources = [
        join("", aws_elasticsearch_domain.default.*.arn),
        "${join("", aws_elasticsearch_domain.default.*.arn)}/*"
      ]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "IpAddress"
        values   = var.allowed_cidr_blocks
        variable = "aws:SourceIp"
      }
    }
  }
}

resource "aws_elasticsearch_domain_policy" "default" {
  count           = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  domain_name     = var.domain_name
  access_policies = join("", data.aws_iam_policy_document.default.*.json)
}


resource "aws_kinesis_stream" "stream" {
  count = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  name  = var.kinesis_stream_name
  # shard_count      = var.kinesis_shard_count # can be defined when PROVISIONED mode enabled
  retention_period = var.kinesis_stream_retention_period

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = var.kinesis_stream_mode
  }

}


resource "aws_iam_role" "firehose" {
  count = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  name  = var.firehose_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "firehose-elasticsearch" {
  count  = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  name   = var.firehose_policy_name
  role   = aws_iam_role.firehose[count.index].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "es:*"
      ],
      "Resource": [
        "${aws_elasticsearch_domain.default[count.index].arn}",
        "${aws_elasticsearch_domain.default[count.index].arn}/*"
      ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:DeleteNetworkInterface"
          ],
          "Resource": [
            "*"
          ]
        },
                {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_elasticsearch_domain.default[count.index].arn}",
                "${aws_elasticsearch_domain.default[count.index].arn}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "es:ESHttpGet"
            ],
            "Resource": [
                "${aws_elasticsearch_domain.default[count.index].arn}/_all/_settings",
                "${aws_elasticsearch_domain.default[count.index].arn}/_cluster/stats",
                "${aws_elasticsearch_domain.default[count.index].arn}/logging/_mapping/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
                "${aws_elasticsearch_domain.default[count.index].arn}/_nodes",
                "${aws_elasticsearch_domain.default[count.index].arn}s/_nodes/*/stats",
                "${aws_elasticsearch_domain.default[count.index].arn}/_stats",
                "${aws_elasticsearch_domain.default[count.index].arn}/logging/_stats"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:eu-west-1:012345678901:log-group:/aws/kinesisfirehose/*:log-stream:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "${aws_kinesis_stream.stream[count.index].arn}"
        }
  ]
}
EOF
}

resource "aws_s3_bucket" "firehose_backup_bucket" {
  count  = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  bucket = var.firehose_bucket_name
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  count      = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  depends_on = [aws_iam_role_policy.firehose-elasticsearch]

  name        = var.firehose_name
  destination = "elasticsearch"
  s3_configuration {
    role_arn   = aws_iam_role.firehose[count.index].arn
    bucket_arn = aws_s3_bucket.firehose_backup_bucket[count.index].arn
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.stream[count.index].arn
    role_arn           = aws_iam_role.firehose[count.index].arn
  }

  elasticsearch_configuration {
    domain_arn            = aws_elasticsearch_domain.default[count.index].arn
    role_arn              = aws_iam_role.firehose[count.index].arn
    index_name            = var.firehose_es_index_name
    index_rotation_period = var.firehose_index_rotation_period
    # type_name  = var.firehose_es_type_name # it is deprecated in Elasticsearch version 7.10

    vpc_config {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_groups # security_group_ids = [aws_security_group.first.id]
      role_arn           = aws_iam_role.firehose[count.index].arn
    }
    cloudwatch_logging_options {
      enabled         = var.cloudwatch_logging_options_enabled
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group[count.index].name
      log_stream_name = aws_cloudwatch_log_stream.firehose_log_stream[count.index].name
    }
  }


}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  count             = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  name              = var.firehose_cw_log_group_name
  retention_in_days = var.firehose_cw_log_group_retention_in_days


}


resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  count          = var.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
  name           = var.firehose_cw_log_stream_name
  log_group_name = aws_cloudwatch_log_group.firehose_log_group[0].name
}


