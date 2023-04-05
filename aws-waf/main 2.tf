resource "aws_wafv2_ip_set" "ipset" {
  count              = length(var.ip_set_addresses) > 0 ? 1 : 0
  ip_address_version = "IPV4"
  scope              = "CLOUDFRONT"
  description        = var.ip_set_description
  name               = var.ip_set_name
  addresses          = var.ip_set_addresses


}

resource "aws_wafv2_web_acl" "waf_acl" {
  count = length(var.ip_set_addresses) > 0 ? 1 : 0
  depends_on = [
    aws_wafv2_ip_set.ipset[0]
  ]
  name        = var.waf_web_acl_name
  description = var.description
  scope       = "CLOUDFRONT"


  default_action {
    block {}
  }

  rule {
    name     = var.metric_name
    priority = 1
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipset[0].arn

      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cw_metrics
      metric_name                = var.metric_name
      sampled_requests_enabled   = var.cw_metrics
    }
  }



  visibility_config {
    cloudwatch_metrics_enabled = var.cw_metrics
    metric_name                = var.metric_name
    sampled_requests_enabled   = var.cw_metrics
  }

}
