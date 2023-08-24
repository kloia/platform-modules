terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9.4"
    }
  }
}
