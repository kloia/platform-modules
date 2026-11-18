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

locals {
  # `aws eks get-token --role-arn` always names the session EKSGetTokenAuth, which a role whose
  # trust requires a specific session name rejects. With var.session_name set, the token is signed
  # as a session of that role assumed with that name instead. Arguments: role ARN, session name,
  # cluster name.
  eks_token_script  = "c=$(aws sts assume-role --role-arn \"$1\" --role-session-name \"$2\" --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text) && set -- \"$3\" $c && unset AWS_PROFILE && AWS_ACCESS_KEY_ID=$2 AWS_SECRET_ACCESS_KEY=$3 AWS_SESSION_TOKEN=$4 exec aws eks get-token --cluster-name \"$1\""
  eks_token_command = var.session_name == null ? "aws" : "sh"
}

provider "kubernetes" {
  alias = "upstream"

  host                   = data.aws_ssm_parameter.upstream_cluster_endpoint.value
  cluster_ca_certificate = base64decode(data.aws_ssm_parameter.upstream_cluster_ca_cert.value)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = var.session_name == null ? ["eks", "get-token", "--role-arn", var.upstream_assume_role_arn, "--cluster-name", data.aws_ssm_parameter.upstream_cluster_name.value] : ["-c", local.eks_token_script, "eks-token", var.upstream_assume_role_arn, var.session_name, data.aws_ssm_parameter.upstream_cluster_name.value]
    command     = local.eks_token_command
  }
}

provider "kubernetes" {
  alias = "downstream"

  host                   = var.downstream_cluster_endpoint
  cluster_ca_certificate = base64decode(var.downstream_cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = var.session_name == null ? ["eks", "get-token", "--role-arn", var.downstream_assume_role_arn, "--cluster-name", var.downstream_cluster_name] : ["-c", local.eks_token_script, "eks-token", var.downstream_assume_role_arn, var.session_name, var.downstream_cluster_name]
    command     = local.eks_token_command
  }
}

# Alternative kubernetes provider that plays a bit nicer with arbitrary manifests
provider "kubectl" {
  alias = "downstream"

  host                   = var.downstream_cluster_endpoint
  cluster_ca_certificate = base64decode(var.downstream_cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = var.session_name == null ? ["eks", "get-token", "--role-arn", var.downstream_assume_role_arn, "--cluster-name", var.downstream_cluster_name] : ["-c", local.eks_token_script, "eks-token", var.downstream_assume_role_arn, var.session_name, var.downstream_cluster_name]
    command     = local.eks_token_command
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

# separate yaml documents
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

resource "kubernetes_env" "cattle_features" {
  count    = var.rancher_agent_already_installed ? 1 : 0
  provider = kubernetes.downstream

  api_version = "apps/v1"
  kind        = "Deployment"
  metadata {
    name      = "cattle-cluster-agent"
    namespace = "cattle-system"
  }

  container = "cluster-register"

  env {
    name  = "CATTLE_FEATURES"
    value = "embedded-cluster-api=false,fleet=false,monitoringv1=false,multi-cluster-management=false,multi-cluster-management-agent=true,provisioningv2=false,rke2=false"
  }

  depends_on = [kubectl_manifest.agent_registration]
}
