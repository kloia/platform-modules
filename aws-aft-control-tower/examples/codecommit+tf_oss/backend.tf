terraform {
    backend "s3" {
        profile  = "inatech-admin"
        bucket   = "terraform-state-112546318254"
        dynamodb_table = "terrafrom-lock-table-112546318254"
        region = "eu-west-1"
        key = "aft-control-tower"
        role_arn = "arn:aws:iam::112546318254:role/AWSAFTExecution"
    }
    required_providers {
      aws = {
        version = " >= 4.9.0"
        source = "registry.terraform.io/hashicorp/aws"
      }
    }
}