terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_shield_subscription (new in this module) requires >= 5.60.0
      # (hashicorp/terraform-provider-aws PR #37637) — bumped from 4.22,
      # which predates that resource and would fail to plan it.
      version = ">= 5.60.0"
    }
  }
}