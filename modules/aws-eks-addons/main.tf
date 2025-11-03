locals {
  can_connect_alb_to_nginx    = var.deploy_aws_loadbalancer && (length(var.connect_hostnames_from_alb_to_nginx) > 0)
  can_connect_alb_to_istio    = var.deploy_aws_loadbalancer && var.deploy_rancher_istio && (length(var.connect_hostnames_from_alb_to_istio) > 0)
  can_connect_nginx_to_argocd = var.deploy_aws_loadbalancer && var.deploy_argocd
  caData                      = var.enable_sso ? data.aws_ssm_parameter.sso_ca_data_network_account[0].value : ""
  ssoURL                      = var.enable_sso ? data.aws_ssm_parameter.sso_url_network_account[0].value : ""
}

resource "kubernetes_service_account" "service-common-service-account" {
  metadata {
    name      = "service-common"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.service_common_iam_role_arn
    }
  }
}

resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = var.loadbalancer_irsa_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }

}

resource "helm_release" "aws_lb_controller" {
  count      = var.deploy_aws_loadbalancer ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.aws_lb_controller_version
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.cluster_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = var.image_repository
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = var.nginx_version
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }

}

resource "kubernetes_ingress_v1" "alb_ingress_connect_nginx" {
  count = local.can_connect_alb_to_nginx ? 1 : 0
  lifecycle {
    ignore_changes = [metadata["*cattle*"]]
  }
  wait_for_load_balancer = true
  metadata {
    name      = var.connect_hostnames_from_alb_ing_prefix != "" ? "${var.connect_hostnames_from_alb_ing_prefix}-nginx" : "ing-nginx"
    namespace = "ingress-nginx"

  }

  spec {
    ingress_class_name = "alb"
    dynamic "rule" {
      for_each = toset(var.connect_hostnames_from_alb_to_nginx)
      content {
        host = rule.key
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "ingress-nginx-controller"
                port {
                  number = 80
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.aws_lb_controller, helm_release.ingress_nginx
  ]
}

resource "kubernetes_annotations" "alb_ingress_connect_nginx_annotation" {
  count       = local.can_connect_alb_to_nginx ? 1 : 0
  api_version = "networking.k8s.io/v1"
  kind        = "Ingress"
  force       = true
  metadata {
    name      = var.connect_hostnames_from_alb_ing_prefix != "" ? "${var.connect_hostnames_from_alb_ing_prefix}-nginx" : "ing-nginx"
    namespace = "ingress-nginx"
  }
  annotations = {
    "alb.ingress.kubernetes.io/load-balancer-name" = var.loadbalancer_name
    "alb.ingress.kubernetes.io/certificate-arn"    = var.acm_certificate_arn
    "alb.ingress.kubernetes.io/wafv2-acl-arn"      = var.waf_acl_arn
    "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"        = "instance"
    "alb.ingress.kubernetes.io/group.name"         = "external"
    "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
    "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
    "alb.ingress.kubernetes.io/healthcheck-path"   = "/healthz"
  }
  depends_on = [
    kubernetes_ingress_v1.alb_ingress_connect_nginx
  ]
}

resource "kubernetes_ingress_v1" "alb_ingress_connect_nginx_internal" {
  count = var.enable_internal_alb ? 1 : 0
  lifecycle {
    ignore_changes = [metadata["*cattle*"]]
  }
  wait_for_load_balancer = true
  metadata {
    name      = var.connect_hostnames_from_alb_internal_ing_prefix != "" ? "${var.connect_hostnames_from_alb_internal_ing_prefix}-nginx-internal" : "ing-nginx-internal"
    namespace = "ingress-nginx"

  }

  spec {
    ingress_class_name = "alb"
    dynamic "rule" {
      for_each = toset(var.connect_hostnames_from_internal_alb_to_nginx)
      content {
        host = rule.key
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "ingress-nginx-controller"
                port {
                  number = 80
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.aws_lb_controller, helm_release.ingress_nginx
  ]
}

resource "kubernetes_annotations" "alb_ingress_connect_internal_nginx_annotation" {
  count = var.enable_internal_alb ? 1 : 0
  api_version = "networking.k8s.io/v1"
  kind        = "Ingress"
  force       = true
  metadata {
    name      = var.connect_hostnames_from_alb_internal_ing_prefix != "" ? "${var.connect_hostnames_from_alb_internal_ing_prefix}-nginx-internal" : "ing-nginx-internal"
    namespace = "ingress-nginx"
  }
  annotations = {
    "alb.ingress.kubernetes.io/load-balancer-name" = var.internal_loadbalancer_name
    "alb.ingress.kubernetes.io/certificate-arn"    = var.acm_certificate_arn
    "alb.ingress.kubernetes.io/wafv2-acl-arn"      = var.internal_waf_acl_arn
    "alb.ingress.kubernetes.io/scheme"             = "internal"
    "alb.ingress.kubernetes.io/target-type"        = "instance"
    "alb.ingress.kubernetes.io/group.name"         = "internal"
    "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
    "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
    "alb.ingress.kubernetes.io/healthcheck-path"   = "/healthz"
  }
  depends_on = [
    kubernetes_ingress_v1.alb_ingress_connect_nginx_internal
  ]
}






resource "kubernetes_ingress_v1" "alb_ingress_connect_istio" {
  count = local.can_connect_alb_to_istio ? 1 : 0
  lifecycle {
    ignore_changes = [metadata["*cattle*"]]
  }
  wait_for_load_balancer = true
  metadata {
    name      = var.connect_hostnames_from_alb_ing_prefix != "" ? "${var.connect_hostnames_from_alb_ing_prefix}-istio" : "ing-istio"
    namespace = "istio-system"

    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name"         = var.loadbalancer_name
      "alb.ingress.kubernetes.io/certificate-arn"            = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/scheme"                     = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"                = "instance"
      "alb.ingress.kubernetes.io/group.name"                 = "external"
      "alb.ingress.kubernetes.io/ssl-redirect"               = "443"
      "alb.ingress.kubernetes.io/listen-ports"               = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/shield-advanced-protection" = tostring(var.enable_shield_advanced_protection_from_alb_to_istio)
    }
  }

  spec {
    ingress_class_name = "alb"
    dynamic "rule" {
      for_each = toset(var.connect_hostnames_from_alb_to_istio)
      content {
        host = rule.key
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "istio-ingressgateway"
                port {
                  number = 80
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.aws_lb_controller
  ]
}


data "aws_ssm_parameter" "sso_ca_data_network_account" {
  provider = aws.network_infra
  count    = var.enable_sso ? 1 : 0
  name     = var.sso_ca_data_network_account
}

data "aws_ssm_parameter" "sso_url_network_account" {
  provider = aws.network_infra
  count    = var.enable_sso ? 1 : 0
  name     = var.sso_url_network_account
}


resource "helm_release" "argocd" {
  count            = var.deploy_argocd ? 1 : 0
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_version

  set {
    name  = "global.domain"
    value = var.argocd_ingress_host
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = var.argocd_ingress_host
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = "password"
  }

  set {
    name  = "server.ingress.pathType"
    value = "Prefix"
  }
  set {
    name  = "server.ingress.annotations.\"ingress\\.kubernetes\\.io/rewrite-target\""
    value = "/"
  }
  set {
    name  = "server.ingress.annotations.\"nginx\\.ingress\\.kubernetes\\.io/backend-protocol\""
    value = "HTTPS"
  }

  set {
    name  = "server.ingress.paths[0]"
    value = "/"
  }
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
  set {
    name  = "server.serviceAccount.annotations.\"eks\\.amazonaws\\.com/role-arn\""
    value = var.argocd_iam_role_arn
  }
  set {
    name  = "controller.serviceAccount.annotations.\"eks\\.amazonaws\\.com/role-arn\""
    value = var.argocd_iam_role_arn
  }
  set {
    name  = "repoServer.serviceAccount.annotations.\"eks\\.amazonaws\\.com/role-arn\""
    value = var.argocd_iam_role_arn
  }
  set {
    name  = "repoServer.initContainers[0].name"
    value = "download-tools"
  }
  set {
    name  = "repoServer.initContainers[0].image"
    value = "alpine:3.8"
  }
  set {
    name  = "repoServer.initContainers[0].command[0]"
    value = "sh"
  }
  set {
    name  = "repoServer.initContainers[0].command[1]"
    value = "-c"
  }
  set {
    name  = "repoServer.initContainers[0].args[0]"
    value = "wget -qO- https://github.com/codacy/helm-ssm/releases/download/3.1.9/helm-ssm-linux.tgz | tar -xvzf - && mv helm-ssm /custom-tools/"
  }
  set {
    name  = "repoServer.initContainers[0].volumeMounts[0].mountPath"
    value = "/custom-tools"
  }
  set {
    name  = "repoServer.initContainers[0].volumeMounts[0].name"
    value = "custom-tools"
  }
  set {
    name  = "repoServer.volumeMounts[0].mountPath"
    value = "/usr/local/bin/helm-ssm"
  }
  set {
    name  = "repoServer.volumeMounts[0].name"
    value = "custom-tools"
  }
  set {
    name  = "repoServer.volumeMounts[0].subPath"
    value = "helm-ssm"
  }
  set {
    name  = "repoServer.volumes[0].name"
    value = "custom-tools"
  }
  set {
    name  = "repoServer.volumes[0].emptyDir"
    value = ""
  }

  values = var.enable_sso || var.enable_template_file ? [templatefile("${path.module}/values.yaml.tpl", {
    caData             = local.caData,
    ssoURL             = local.ssoURL,
    redirectURI        = "${var.sso_callback_url}",
    entityIssuer       = "${var.sso_callback_url}",
    currentEnvironment = "${var.current_environment}"
    })
  ] : []

  // SSO Values
  // configmap url
  dynamic "set" {
    for_each = var.enable_sso ? [1] : []
    content {
      name  = "configs.cm.url"
      value = var.gitops_url
    }
  }

  depends_on = [
    kubernetes_ingress_v1.alb_ingress_connect_nginx
  ]

}

resource "helm_release" "crossplane" {
  count            = var.deploy_crossplane ? 1 : 0
  name             = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane"
  namespace        = "crossplane-system"
  create_namespace = true
}


resource "kubectl_manifest" "crossplane_aws_controller" {
  count      = var.deploy_crossplane ? 1 : 0
  yaml_body  = <<YAML
apiVersion: pkg.crossplane.io/v1alpha1
kind: ControllerConfig
metadata:
  name: aws-config
  annotations:
    eks.amazonaws.com/role-arn: ${var.crossplane_irsa_arn}
spec:
  podSecurityContext:
    fsGroup: 2000
YAML
  depends_on = [helm_release.crossplane]
}

resource "kubectl_manifest" "crossplane_aws_provider" {
  count      = var.deploy_crossplane ? 1 : 0
  yaml_body  = <<YAML
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: crossplanecontrib/provider-aws:v0.34.0
  controllerConfigRef:
    name: aws-config
YAML
  depends_on = [helm_release.crossplane, kubectl_manifest.crossplane_aws_controller]
}

resource "kubectl_manifest" "crossplane_aws_provider_config" {
  count     = var.deploy_crossplane ? 1 : 0
  yaml_body = <<YAML
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: aws-provider
spec:
  credentials:
    source: InjectedIdentity
YAML
  depends_on = [
    kubectl_manifest.crossplane_aws_controller,
    kubectl_manifest.crossplane_aws_provider
  ]
}


resource "helm_release" "external-secrets" {
  count            = var.deploy_external_secrets ? 1 : 0
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.eso_iam_role_arn
  }
}


locals {
  # rancher monitoring MUST be deployed when rancher istio is enabled.
  deploy_rancher_istio      = var.deploy_rancher_istio
  deploy_rancher_monitoring = var.deploy_rancher_monitoring || var.deploy_rancher_istio
}

resource "kubectl_manifest" "argocd_bootstrapper_application" {
  count = var.deploy_argocd ? 1 : 0
  yaml_body = yamlencode({
    apiVersion : "argoproj.io/v1alpha1"
    kind : "Application"
    metadata : {
      name : "argo-bootstrapper"
      namespace : "argocd"
    }
    spec : {
      project : "default"
      source : {
        repoURL : "https://github.com/kloia/ArgoCD-EKS-Bootstrapper.git"
        targetRevision : "HEAD"
        path : "helm"
        helm : {
          values : yamlencode({
            certManager : merge({
              enable : var.deploy_cert_manager
            }, var.cert_manager_version == null ? {} : {
              targetRevision : var.cert_manager_version
            })
            metricsServer : merge({
              enable : var.deploy_metrics_server
            }, var.metrics_server_version == null ? {} : {
              targetRevision : var.metrics_server_version
            })
            trivy : merge({
              enable : var.deploy_trivy
            }, var.trivy_version == null ? {} : {
              targetRevision : var.trivy_version
            })
            rancher : merge({
              enable : var.deploy_rancher
              values : {
                hostname : var.rancher_hostname
              }
            }, var.rancher_version == null ? {} : {
              targetRevision : var.rancher_version
            })
            rancherMonitoringCrd : merge({
              enable : local.deploy_rancher_monitoring
            }, var.rancher_monitoring_crd_version == null ? {} : {
              targetRevision : var.rancher_monitoring_crd_version
            })
            rancherMonitoring : merge({
              enable : local.deploy_rancher_monitoring
            }, var.rancher_monitoring_version == null ? {} : {
              targetRevision : var.rancher_monitoring_version
            })
            rancherIstio : merge({
              enable : local.deploy_rancher_istio
            }, var.rancher_istio_version == null ? {} : {
              targetRevision : var.rancher_istio_version
            })
            argoWorkflow : merge({
              enable : var.deploy_argo_workflow
              values : {
                server : {
                  ingress : {
                    enabled : true
                    hosts : ["${var.argo_workflow_ingress_host}"]
                  }
                  extraArgs : var.argo_workflow_extra_args
                }
              }
            }, var.argo_workflow_version == null ? {} : {
              targetRevision : var.argo_workflow_version
            })
            rancherLogging : merge({
              enable : var.deploy_rancher_logging
              values : {
                fluentd : {
                  resources : {
                    limits : {
                      memory : var.rancher_logging_fluentd_memory_limit
                      cpu : var.rancher_logging_fluentd_cpu_limit
                    }
                    requests : {
                      memory : var.rancher_logging_fluentd_memory_request
                      cpu : var.rancher_logging_fluentd_cpu_request
                    }
                  }

                }
              }
            }, var.rancher_logging_version == null ? {} : {
              targetRevision : var.rancher_logging_version
            })
          })
        }
      }
      destination : {
        server : "https://kubernetes.default.svc"
        namespace : "argocd"
      }
      syncPolicy : {
        automated : {}
      }
    }
  })
  depends_on = [helm_release.argocd]
  lifecycle {
    ignore_changes = all
  }
}



# Karpenter Configuration

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia_provider
}

module "karpenter" {

  source = "git::https://github.com/kloia/platform-modules.git//aws-eks/modules/karpenter?ref=v0.0.47"

  cluster_name = var.cluster_name

  create = var.deploy_karpenter

  irsa_oidc_provider_arn          = var.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  provider_region                 = var.cluster_region
  provider_assume_role_arn        = var.assume_role_arn

  # Since Karpenter is running on an EKS Managed Node group,
  # we can re-use the role that was created for the node group
  create_iam_role = false
  iam_role_arn    = var.eks_managed_node_groups_iam_role_arn
}

resource "helm_release" "karpenter" {
  depends_on = [
    module.karpenter
  ]
  count = var.deploy_karpenter ? 1 : 0

  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = var.karpenter_version

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[0].key"
    value = "workload"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[0].value"
    value = "system"
  }

  set {
    name  = "hostNetwork"
    value = true
  }

}

resource "kubectl_manifest" "karpenter_stateful_provisioner" {
  count = var.deploy_karpenter && var.deploy_karpenter_crds ? 1 : 0

  yaml_body = yamlencode({
    apiVersion : "karpenter.sh/v1alpha5"
    kind : "Provisioner"
    metadata : {
      name : "stateful-provisioner"
      namespace : "karpenter"
    }
    spec : {
      consolidation : {
        enabled = false
      }
      providerRef = {
        name = "default"
      }
      limits = {
        resources = {
          cpu = var.stateful_total_cpu_limit
        }
      }
      taints = [
        {
          effect = "NoSchedule"
          key    = "workload"
          value  = var.stateful_application_toleration_value
        },
      ]
      requirements : [
        {
          key      = "workload"
          operator = "In"
          values = [
            var.stateful_application_toleration_value,
          ]
        },
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = var.stateful_capacity_types
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.stateful_instance_types
        },
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = var.stateful_instance_zones
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = var.stateful_arch_types
        },
        {
          key      = "kubernetes.io/os"
          operator = "In"
          values = [
            "linux",
          ]
        },
      ]
    }
  })


  depends_on = [
    helm_release.karpenter[0]
  ]
}


# there is no taint necessary for stateless applicatinos (system workloads will be scheduled at default eks node group(it will have system workload taint ))
resource "kubectl_manifest" "karpenter_stateless_provisioner" {
  count = var.deploy_karpenter && var.deploy_karpenter_crds ? 1 : 0

  yaml_body = yamlencode({
    apiVersion : "karpenter.sh/v1alpha5"
    kind : "Provisioner"
    metadata : {
      name : "stateless-provisioner"
    }
    spec : {
      consolidation : {
        enabled = true
      }
      providerRef = {
        name = "default"
      }
      limits = {
        resources = {
          cpu = var.stateless_total_cpu_limit
        }
      }
      requirements : [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = var.stateless_capacity_types
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.stateless_instance_types
        },
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = var.stateless_instance_zones
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = var.stateless_arch_types
        },
        {
          key      = "kubernetes.io/os"
          operator = "In"
          values = [
            "linux",
          ]
        },
      ]
    }
  })


  depends_on = [
    helm_release.karpenter[0]
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  count     = var.deploy_karpenter && var.deploy_karpenter_crds ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: ${var.karpenter_node_template_volume_size}
            volumeType: ${var.karpenter_node_template_volume_type}
            iops: ${var.karpenter_node_template_volume_iops}
            deleteOnTermination: ${var.karpenter_node_template_delete_on_termination}
            throughput: ${var.karpenter_node_template_throughput}

      subnetSelector:
        karpenter.sh/discovery: "true"
      securityGroupSelector:
        karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter[0]
  ]
}

resource "kubectl_manifest" "karpenter_windows_with_aws_cni" {
  count      = var.karpenter_windows_support ? 1 : 0
  yaml_body  = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: amazon-vpc-cni
  namespace: kube-system
data:
  enable-windows-ipam: "true"
YAML
  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_stateless_windows2019_provisioner" {
  count = var.karpenter_windows_support ? 1 : 0
  yaml_body = yamlencode({
    apiVersion : "karpenter.sh/v1alpha5"
    kind : "Provisioner"
    metadata : {
      name : "stateless-windows2019-provisioner"
    }
    spec : {
      ttlSecondsAfterEmpty = 30
      providerRef = {
        name = "windows2019"
      }
      limits = {
        resources = {
          cpu = var.stateless_total_cpu_limit
        }
      }
      requirements : [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = var.stateless_windows_capacity_types
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.stateless_windows_instance_types
        },
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = var.stateless_instance_zones
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = var.stateless_windows_arch_types
        },
        {
          key      = "kubernetes.io/os"
          operator = "In"
          values = [
            "windows",
          ]
        },
      ]
    }
  })
  depends_on = [
    helm_release.karpenter[0]
  ]
}

resource "kubectl_manifest" "karpenter_stateless_windows2022_provisioner" {
  count = var.karpenter_windows_support ? 1 : 0
  yaml_body = yamlencode({
    apiVersion : "karpenter.sh/v1alpha5"
    kind : "Provisioner"
    metadata : {
      name : "stateless-windows2022-provisioner"
    }
    spec : {
      ttlSecondsAfterEmpty = 30
      providerRef = {
        name = "windows2022"
      }
      limits = {
        resources = {
          cpu = var.stateless_total_cpu_limit
        }
      }
      requirements : [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = var.stateless_windows_capacity_types
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.stateless_windows_instance_types
        },
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = var.stateless_instance_zones
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = var.stateless_windows_arch_types
        },
        {
          key      = "kubernetes.io/os"
          operator = "In"
          values = [
            "windows"
          ]
        },
      ]
    }
  })
  depends_on = [
    helm_release.karpenter[0]
  ]
}

resource "kubectl_manifest" "karpenter_windows2019_node_template" {
  count     = var.karpenter_windows_support ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: windows2019
    spec:
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: ${var.karpenter_node_template_volume_size}
            volumeType: ${var.karpenter_node_template_volume_type}
            iops: ${var.karpenter_node_template_volume_iops}
            deleteOnTermination: ${var.karpenter_node_template_delete_on_termination}
            throughput: ${var.karpenter_node_template_throughput}
      subnetSelector:
        karpenter.sh/discovery: "true"
      securityGroupSelector:
        karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
      amiFamily: Windows2019
      metadataOptions:
        httpEndpoint: enabled
        httpProtocolIPv6: disabled
        httpPutResponseHopLimit: 2
        httpTokens: required
  YAML

  depends_on = [
    helm_release.karpenter[0]
  ]
}

resource "kubectl_manifest" "karpenter_windows2022_node_template" {
  count     = var.karpenter_windows_support ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: windows2022
    spec:
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: ${var.karpenter_node_template_volume_size}
            volumeType: ${var.karpenter_node_template_volume_type}
            iops: ${var.karpenter_node_template_volume_iops}
            deleteOnTermination: ${var.karpenter_node_template_delete_on_termination}
            throughput: ${var.karpenter_node_template_throughput}
      subnetSelector:
        karpenter.sh/discovery: "true"
      securityGroupSelector:
        karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
      amiFamily: Windows2022
      metadataOptions:
        httpEndpoint: enabled
        httpProtocolIPv6: disabled
        httpPutResponseHopLimit: 2
        httpTokens: required
  YAML

  depends_on = [
    helm_release.karpenter[0]
  ]
}


resource "kubectl_manifest" "deploy_adot_collector_service_account" {
  count     = var.deploy_adot_collector ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        eks.amazonaws.com/role-arn: ${var.adot_collector_role}
      name:  ${var.adot_collector_service_account}
      namespace: ${var.adot_collector_namespace}
  YAML
}

resource "kubectl_manifest" "deploy_adot_collector" {
  count     = var.deploy_adot_collector ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: opentelemetry.io/v1alpha1
    kind: OpenTelemetryCollector
    metadata:
      name: adot
      namespace: ${var.adot_collector_namespace}
    spec:
      mode: deployment
      serviceAccount: ${var.adot_collector_service_account}
      managementState: managed
      podDisruptionBudget:
        maxUnavailable: 1
      replicas: 2
      targetAllocator:
        prometheusCR:
          scrapeInterval: 30s
      upgradeStrategy: automatic
      config: |
        receivers:
          awsxray:
            transport: udp
          otlp:
            protocols:
              grpc:
                endpoint: 0.0.0.0:4317
              http:
                endpoint: 0.0.0.0:4318
        processors:

        exporters:
          awsxray:
            region:  ${var.cluster_region}
        service:
          pipelines:
            traces:
              receivers: [awsxray, otlp]
              processors: []
              exporters: [awsxray]
  YAML
}

resource "kubectl_manifest" "deploy_adot_collector_ingress" {
  count     = var.deploy_adot_collector ? 1 : 0
  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        nginx.ingress.kubernetes.io/configuration-snippet: |
          more_set_headers "Access-Control-Allow-Origin: $http_origin";
        nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
        nginx.ingress.kubernetes.io/cors-allow-headers: Content-Type, authorization, x-ms-request-id,
          x-ms-request-root-id, x-originating-page
        nginx.ingress.kubernetes.io/cors-allow-methods: PUT, GET, POST, OPTIONS, DELETE
        nginx.ingress.kubernetes.io/cors-allow-origin: "*"
        nginx.ingress.kubernetes.io/enable-cors: "true"
      name: adot-collector
      namespace: ${var.adot_collector_namespace}
    spec:
      ingressClassName: nginx
      rules:
      - host: ${var.adot_collector_hostname}
        http:
          paths:
          - backend:
              service:
                name: adot-collector
                port:
                  number: 4318
            path: /
            pathType: Prefix
  YAML
}
