# Collect the creds from AWS SSM
data "aws_ssm_parameter" "upstream_cluster_name" {
  provider = aws.shared_infra
  name     = var.upstream_cluster_name_ssm_key
}
data "aws_ssm_parameter" "upstream_cluster_endpoint" {
  provider = aws.shared_infra
  name     = var.upstream_cluster_endpoint_ssm_key
}
data "aws_ssm_parameter" "upstream_cluster_ca_cert" {
  provider = aws.shared_infra
  name     = var.upstream_cluster_ca_cert_ssm_key
}

provider "kubernetes" {
  alias = "upstream"

  host                   = data.aws_ssm_parameter.upstream_cluster_endpoint.value
  cluster_ca_certificate = base64decode(data.aws_ssm_parameter.upstream_cluster_ca_cert.value)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--role-arn", var.upstream_assume_role_arn, "--cluster-name", data.aws_ssm_parameter.upstream_cluster_name.value]
    command     = "aws"
  }
}

locals {
  rancher_cluster_name = var.rancher_cluster_name != "" ? var.rancher_cluster_name : var.downstream_cluster_name
}

# This only creates the provisioning. The cluster will be imported
# after `aws-eks-rancher-joiner` applies the join manifests from the
# resulting import.
resource "kubernetes_manifest" "cluster_provisioning" {
  provider = kubernetes.upstream

  manifest = {
    apiVersion = "provisioning.cattle.io/v1"
    kind       = "Cluster"
    metadata = {
      # TODO: namespace can be non-default
      namespace = "fleet-default"
      name      = local.rancher_cluster_name
    }
    # The empty spec has been lifted straight from
    # Rancher's UI when importing an existing cluster.
    spec = {
      localClusterAuthEndpoint = {}
    }
  }

  wait {
    fields = {
      "status.clusterName" = "*"
    }
  }
}

