terraform {
  required_version = ">= 0.13.1"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.4.5"
    }
  }
}
