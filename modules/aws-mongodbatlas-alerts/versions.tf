terraform {
  required_version = ">= 1.3.0"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 2.10.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
