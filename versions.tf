terraform {
  required_version = ">= v0.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.38"
    }
  }
}
