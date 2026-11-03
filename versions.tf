terraform {
  # check blocks need Terraform 1.5.
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # The upstream metric-alarm module 5.7.3 requires >= 5.81.
      version = ">= 5.81"
    }
  }
}
