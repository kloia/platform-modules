terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

