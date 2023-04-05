locals {
  create_origin_access_identity = var.create_origin_access_identity && length(keys(var.origin_access_identities)) > 0
  # create_s3_bucket = var.create_s3_bucket && length(var.s3_bucket_name) > 0
}



resource "aws_cloudfront_origin_access_identity" "this" {
  for_each = local.create_origin_access_identity ? var.origin_access_identities : {}

  comment = each.value

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  provider = aws.shared_infra
  count = length(var.aliases) > 0 ? 1: 0
  name         = var.zone_name
  private_zone = false
}

data "aws_s3_bucket" "existing_bucket" {
  count = var.s3_bucket_name != "" && var.create_s3_bucket == false ? 1 : 0
  bucket = var.s3_bucket_name
  provider = aws.ireland
}

resource "aws_route53_record" "this" {
  provider = aws.shared_infra
  count = length(var.aliases)
  zone_id = data.aws_route53_zone.selected[0].id
  name    = var.aliases[count.index]
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "this" {
    provider = aws.ireland
    count = var.create_origin_access_identity && var.create_s3_bucket ? 1 : 0
    bucket = var.s3_bucket_name
    # object_ownership = var.object_ownership
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count = ((length(var.cors_rule)>0?true:false)&&var.create_origin_access_identity)?1:0
  provider              = aws.ireland
  bucket                = aws_s3_bucket.this[0].id
  #expected_bucket_owner = var.expected_bucket_owner

  dynamic "cors_rule" {
    for_each = var.cors_rule

    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.AllowedMethods
      allowed_origins = cors_rule.value.AllowedOrigins
      allowed_headers = try(cors_rule.value.AllowedHeaders, null)
      expose_headers  = try(cors_rule.value.ExposeHeaders, null)
      max_age_seconds = try(cors_rule.value.MaxAgeSeconds, null)
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  provider = aws.ireland
  for_each = local.create_origin_access_identity && var.create_s3_bucket ? var.origin_access_identities : {}
  bucket = aws_s3_bucket.this[0].id
  policy = jsonencode(
{
    Version= "2008-10-17",
    Id= "PolicyForCloudFrontPrivateContent",
    Statement= [
        {
            Sid= "1",
            Effect= "Allow",
            Principal = {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.this[each.key].id}"
            },
            Action = "s3:GetObject",
            Resource = var.bucket_policy_resources == null ? ["arn:aws:s3:::${aws_s3_bucket.this[0].id}/*"] : var.bucket_policy_resources # split(",",var.bucket_policy_resources)
                        
        },
    ]
}
)
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.control_object_ownership ? 1 : 0
  provider = aws.ireland
  bucket = aws_s3_bucket.this[0].id # local.create_origin_access_identity ? aws_s3_bucket_policy.s3_policy[0].id : aws_s3_bucket.this[0].id

  rule {
    object_ownership = var.object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [
    aws_s3_bucket_policy.s3_policy,
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = length(keys(var.website)) > 0 ? 1 : 0
  provider = aws.ireland
  bucket   = aws_s3_bucket.this[0].id

  dynamic "index_document" {
    for_each = try([var.website["index_document"]], [])

    content {
      suffix = index_document.value
    }
  }

  dynamic "error_document" {
    for_each = try([var.website["error_document"]], [])

    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = try([var.website["redirect_all_requests_to"]], [])

    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = try(redirect_all_requests_to.value.protocol, null)
    }
  }

  dynamic "routing_rule" {
    for_each = try(flatten([var.website["routing_rules"]]), [])

    content {
      dynamic "condition" {
        for_each = [try([routing_rule.value.condition], [])]

        content {
          http_error_code_returned_equals = try(routing_rule.value.condition["http_error_code_returned_equals"], null)
          key_prefix_equals               = try(routing_rule.value.condition["key_prefix_equals"], null)
        }
      }

      redirect {
        host_name               = try(routing_rule.value.redirect["host_name"], null)
        http_redirect_code      = try(routing_rule.value.redirect["http_redirect_code"], null)
        protocol                = try(routing_rule.value.redirect["protocol"], null)
        replace_key_prefix_with = try(routing_rule.value.redirect["replace_key_prefix_with"], null)
        replace_key_with        = try(routing_rule.value.redirect["replace_key_with"], null)
      }
    }
  }
}


resource "aws_cloudfront_distribution" "this" {
  depends_on = [
    aws_cloudfront_origin_request_policy.this[0]
  ]
  count = var.create_distribution ? 1 : 0

  aliases             = var.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id
  tags                = var.tags

  dynamic "logging_config" {
    for_each = length(keys(var.logging_config)) == 0 ? [] : [var.logging_config]

    content {
      bucket          = logging_config.value["bucket"]
      prefix          = lookup(logging_config.value, "prefix", null)
      include_cookies = lookup(logging_config.value, "include_cookies", null)
    }
  }

  dynamic "origin" {
    for_each = var.origin

    content {
      domain_name              = var.cloudfront_elb ? lookup(origin.value, "domain_name",origin.key) : lookup(origin.value, "domain_name", 
                                  var.s3_bucket_name != "" && var.create_s3_bucket == false ? data.aws_s3_bucket.existing_bucket[0].bucket_domain_name : aws_s3_bucket.this[0].bucket_domain_name)
      origin_id                = lookup(origin.value, "origin_id", origin.key)
      origin_path              = lookup(origin.value, "origin_path", "")
      connection_attempts      = lookup(origin.value, "connection_attempts", null)
      connection_timeout       = lookup(origin.value, "connection_timeout", null)
      origin_access_control_id = lookup(origin.value, "origin_access_control_id", null)

      dynamic "s3_origin_config" {
        for_each = length(keys(lookup(origin.value, "s3_origin_config", {}))) == 0 ? [] : [lookup(origin.value, "s3_origin_config", {})]

        content {
          origin_access_identity = lookup(s3_origin_config.value, "cloudfront_access_identity_path", lookup(lookup(aws_cloudfront_origin_access_identity.this, lookup(s3_origin_config.value, "origin_access_identity", ""), {}), "cloudfront_access_identity_path", null))
        }
      }

      dynamic "custom_origin_config" {
        for_each = length(lookup(origin.value, "custom_origin_config", "")) == 0 ? [] : [lookup(origin.value, "custom_origin_config", "")]

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_header", [])

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "origin_shield" {
        for_each = length(keys(lookup(origin.value, "origin_shield", {}))) == 0 ? [] : [lookup(origin.value, "origin_shield", {})]

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.origin_group

    content {
      origin_id = lookup(origin_group.value, "origin_id", origin_group.key)

      failover_criteria {
        status_codes = origin_group.value["failover_status_codes"]
      }

      member {
        origin_id = origin_group.value["primary_member_origin_id"]
      }

      member {
        origin_id = origin_group.value["secondary_member_origin_id"]
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = [var.default_cache_behavior]
    iterator = i

    content {
      target_origin_id       = var.cloudfront_elb ? lookup(i.value, "domain_name", "") : (var.s3_bucket_name != "" && var.create_s3_bucket == false ? data.aws_s3_bucket.existing_bucket[0].id : aws_s3_bucket.this[0].id)
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)
      trusted_key_groups        = lookup(i.value, "trusted_key_groups", null)

      cache_policy_id            = var.create_and_attach_origin_request_policy||lookup(i.value, "managed_cache_disabled_policy",false) ? data.aws_cloudfront_cache_policy.managed_cache_disabled.id : lookup(i.value, "cache_policy_id", null)
      origin_request_policy_id   = var.create_and_attach_origin_request_policy ? aws_cloudfront_origin_request_policy.this[0].id : ( 
                                                                                        lookup(i.value,"origin_request_policy_id",null) == "managed_origin_request_policy" ? data.aws_cloudfront_origin_request_policy.managed_origin_request_policy.id:lookup(i.value,"origin_request_policy_id",null )
                                                                                        )
      response_headers_policy_id = lookup(i.value, "response_headers_policy_id", null)
      realtime_log_config_arn    = lookup(i.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

        content {
          query_string            = lookup(i.value, "query_string", false)
          query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
          headers                 = lookup(i.value, "headers", [])

          cookies {
            forward           = lookup(i.value, "cookies_forward", "none")
            whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(i.value, "function_association", [])
        iterator = f

        content {
          event_type   = f.key
          function_arn = f.value.function_arn
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    iterator = i

    content {
      path_pattern           = i.value["path_pattern"]
      target_origin_id       = var.cloudfront_elb ? lookup(i.value, "domain_name", "") : aws_s3_bucket.this[0].id
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)
      trusted_key_groups        = lookup(i.value, "trusted_key_groups", null)

      cache_policy_id            = lookup(i.value, "cache_policy_id", null)
      origin_request_policy_id   = lookup(i.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(i.value, "response_headers_policy_id", null)
      realtime_log_config_arn    = lookup(i.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

        content {
          query_string            = lookup(i.value, "query_string", false)
          query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
          headers                 = lookup(i.value, "headers", [])

          cookies {
            forward           = lookup(i.value, "cookies_forward", "none")
            whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(i.value, "function_association", [])
        iterator = f

        content {
          event_type   = f.key
          function_arn = f.value.function_arn
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = lookup(var.viewer_certificate, "acm_certificate_arn", null)
    cloudfront_default_certificate = lookup(var.viewer_certificate, "cloudfront_default_certificate", null)
    iam_certificate_id             = lookup(var.viewer_certificate, "iam_certificate_id", null)

    minimum_protocol_version = lookup(var.viewer_certificate, "minimum_protocol_version", "TLSv1")
    ssl_support_method       = lookup(var.viewer_certificate, "ssl_support_method", null)
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_code = custom_error_response.value["error_code"]

      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = lookup(geo_restriction.value, "restriction_type", "none")
        locations        = lookup(geo_restriction.value, "locations", [])
      }
    }
  }
}

resource "aws_cloudfront_monitoring_subscription" "this" {
  count = var.create_distribution && var.create_monitoring_subscription ? 1 : 0

  distribution_id = aws_cloudfront_distribution.this[0].id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = var.realtime_metrics_subscription_status
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "this" {
    count = var.create_distribution && var.create_and_attach_origin_request_policy ? 1 : 0
    name    = var.origin_request_policy_name
    comment = "origin request policy includes the following headers"
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = var.origin_request_policy_headers
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  
}


data "aws_cloudfront_cache_policy" "managed_cache_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_origin_request_policy" {
  name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}
