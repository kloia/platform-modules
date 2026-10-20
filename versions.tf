terraform {
  required_version = ">= 1.3.0"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.4.5"
    }
  }
}
