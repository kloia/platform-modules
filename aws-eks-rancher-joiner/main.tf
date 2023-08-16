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
    args = [
      "eks", "get-token", "--role-arn", var.upstream_assume_role_arn, "--cluster-name",
      data.aws_ssm_parameter.upstream_cluster_name.value
    ]
    command = "aws"
  }
}

# Alternative kubernetes provider that plays a bit nicer with arbitrary manifests
provider "kubectl" {
  alias = "downstream"

  host                   = var.downstream_cluster_endpoint
  cluster_ca_certificate = base64decode(var.downstream_cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args = [
      "eks", "get-token", "--role-arn", var.downstream_assume_role_arn, "--cluster-name",
      var.downstream_cluster_name
    ]
    command = "aws"
  }
}

locals {
  rancher_cluster_name = var.rancher_cluster_name != "" ? var.rancher_cluster_name : var.downstream_cluster_name
}

# Fetch the internal cluster name from the resource created in `aws-eks-rancher-cluster-joiner`
data "kubernetes_resource" "cluster_provisioning" {
  provider = kubernetes.upstream

  api_version = "provisioning.cattle.io/v1"
  kind        = "Cluster"
  metadata {
    namespace = "fleet-default"
    name      = local.rancher_cluster_name
  }
}

locals {
  rancher_internal_cluster_name = data.kubernetes_resource.cluster_provisioning.object["status"]["clusterName"]
}

# Rancher created resource, which includes the manifest that needs to be applied to the downstream cluster
data "kubernetes_resource" "cluster_registration_token" {
  provider = kubernetes.upstream
  depends_on = [
    data.kubernetes_resource.cluster_provisioning,
  ]

  api_version = "management.cattle.io/v3"
  kind        = "ClusterRegistrationToken"
  metadata {
    # quirk of rancher, this resource is created under a namespace with the cluster's internal name (e.g. c-m-3fd34h)
    namespace = local.rancher_internal_cluster_name
    name      = "default-token"
  }
}

# The manifest that sets up the Rancher agent on the downstream cluster
data "http" "agent_registration_manifest" {
  depends_on = [
    data.kubernetes_resource.cluster_registration_token,
  ]

  url = data.kubernetes_resource.cluster_registration_token.object["status"]["manifestUrl"]
}

data "kubectl_file_documents" "agent_registration_manifest" {
  content = data.http.agent_registration_manifest.response_body
}

# Apply the registration manifest to downstream, which finally makes it join upstream.
resource "kubectl_manifest" "agent_registration" {
  for_each = data.kubectl_file_documents.agent_registration_manifest.manifests
  provider = kubectl.downstream

  yaml_body = each.value

  depends_on = [data.http.agent_registration_manifest]
  lifecycle {
    # No need to apply again if downstream is already joined
    ignore_changes = [yaml_body]
  }
}
