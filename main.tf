data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "kubectl_file_documents" "file_manifest" {
  for_each = {
    for i, manifest_file in var.kubectl_manifest_files : i => manifest_file if length(var.kubectl_manifest_files) > 0
  }
  content = each.value
}

locals {
  helm_releases = {
    for i, release in var.helm_releases : i => merge(
      {
        name = coalesce(release.name, i)
      },
      release,
    )
  }

  kubectl_manifest = flatten([
    for i, manifest_file in var.kubectl_manifest_files : [
      for j, manifest in data.kubectl_file_documents.file_manifest[i].manifests : {
        id       = format("%s_%s", i, j)
        manifest = manifest
      } if length(data.kubectl_file_documents.file_manifest[i].manifests) > 0
    ] if length(var.kubectl_manifest_files) > 0
  ])

  kubectl_manifest_map = {
    for i, manifest in local.kubectl_manifest : format("%s", manifest.id) => manifest
  }
}

resource "kubectl_manifest" "file_manifest" {
  for_each  = local.kubectl_manifest_map
  yaml_body = lookup(each.value, "manifest", null)
}

resource "helm_release" "release" {
  for_each = {
    for i in local.helm_releases : format("%s_%s", var.eks_cluster_name, i.name) => i
  }

  name                       = lookup(each.value, "name", each.key)
  chart                      = lookup(each.value, "chart", null)
  repository                 = lookup(each.value, "repository", null)
  repository_cert_file       = lookup(each.value, "repository_cert_file", null)
  repository_key_file        = lookup(each.value, "repository_key_file", null)
  repository_ca_file         = lookup(each.value, "repository_ca_file", null)
  repository_username        = lookup(each.value, "repository_username", null)
  repository_password        = lookup(each.value, "repository_password", null)
  devel                      = lookup(each.value, "devel", null)
  version                    = lookup(each.value, "version", null)
  namespace                  = lookup(each.value, "namespace", null)
  verify                     = lookup(each.value, "verify", null)
  keyring                    = lookup(each.value, "keyring", null)
  timeout                    = lookup(each.value, "timeout", null)
  disable_webhooks           = lookup(each.value, "disable_webhooks", null)
  reuse_values               = lookup(each.value, "reuse_values", null)
  reset_values               = lookup(each.value, "reset_values", null)
  force_update               = lookup(each.value, "force_update", null)
  recreate_pods              = lookup(each.value, "recreate_pods", null)
  cleanup_on_fail            = lookup(each.value, "cleanup_on_fail", null)
  max_history                = lookup(each.value, "max_history", null)
  atomic                     = lookup(each.value, "atomic", null)
  skip_crds                  = lookup(each.value, "skip_crds", null)
  render_subchart_notes      = lookup(each.value, "render_subchart_notes", null)
  disable_openapi_validation = lookup(each.value, "disable_openapi_validation", null)
  wait                       = lookup(each.value, "wait", null)
  wait_for_jobs              = lookup(each.value, "wait_for_jobs", null)
  values                     = lookup(each.value, "values", null)

  dependency_update = lookup(each.value, "dependency_update", null)
  replace           = lookup(each.value, "replace", null)
  description       = lookup(each.value, "description", null)

  pass_credentials = lookup(each.value, "pass_credentials", null)
  lint             = lookup(each.value, "lint", null)
  create_namespace = lookup(each.value, "create_namespace", null)
}
