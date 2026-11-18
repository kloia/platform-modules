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

