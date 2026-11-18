locals {
  # `aws eks get-token --role-arn` always names the session EKSGetTokenAuth, which a role whose
  # trust requires a specific session name rejects. With var.session_name set, the token is signed
  # as a session of that role assumed with that name instead. Arguments: role ARN, session name,
  # cluster name.
  eks_token_script  = "c=$(aws sts assume-role --role-arn \"$1\" --role-session-name \"$2\" --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text) && set -- \"$3\" $c && unset AWS_PROFILE && AWS_ACCESS_KEY_ID=$2 AWS_SECRET_ACCESS_KEY=$3 AWS_SESSION_TOKEN=$4 exec aws eks get-token --cluster-name \"$1\""
  eks_token_command = var.session_name == null ? "aws" : "sh"
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = var.session_name == null ? ["eks", "get-token", "--role-arn", var.assume_role_arn, "--cluster-name", var.cluster_name] : ["-c", local.eks_token_script, "eks-token", var.assume_role_arn, var.session_name, var.cluster_name]
    command     = local.eks_token_command
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = var.session_name == null ? ["eks", "get-token", "--role-arn", var.assume_role_arn, "--cluster-name", var.cluster_name] : ["-c", local.eks_token_script, "eks-token", var.assume_role_arn, var.session_name, var.cluster_name]
      command     = local.eks_token_command
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 20
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = var.session_name == null ? ["eks", "get-token", "--role-arn", var.assume_role_arn, "--cluster-name", var.cluster_name] : ["-c", local.eks_token_script, "eks-token", var.assume_role_arn, var.session_name, var.cluster_name]
    command     = local.eks_token_command
  }
}

provider "time" {
}


terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.15.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia_provider"
  default_tags {
    tags = {
      Environment = "us east 1 virginia"
    }
  }
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.session_name
  }
}