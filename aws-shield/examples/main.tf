provider "aws" {
  default_tags {
    tags = {
      name = "example"
      environment = "dev"
      terraform   = "true"
    }
  }
}

module "group_all" {
  source = "../group_all"
  group_id = "example"
  aggregation = "SUM"
}

module "group_arbitrary" {
  source  = "../group_arbitrary"
  name    = "example"
  aggregation = "SUM"
  members = ["arn:aws:ec2:eu-west-1:2131241241241:eip-allocation/<aws_eip>"]
}

module "resource_type_protection_group" {
  source = "../group_resource_type"
  resource_type_protection_group = [
    {
        group_id      = "cloudfront_distributions"
        aggregation   = "SUM"
        members       = ["arn:aws:ec2:eu-west-1:2131241241241:eip-allocation/<aws_eip>"]
        resource_type = "CLOUDFRONT_DISTRIBUTION"
    },
    {
        group_id      = "route53_hosted_zones"
        aggregation   = "SUM"
        members       = ["arn:aws:ec2:eu-west-1:2131241241241:eip-allocation/<aws_eip>"]
        resource_type = "ROUTE_53_HOSTED_ZONE"
    }
  ]
}
