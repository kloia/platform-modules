locals {
  can_connect_alb_to_nginx = var.deploy_aws_loadbalancer && (length(var.connect_hostnames_from_alb_to_nginx) > 0)
  can_connect_alb_to_istio = var.deploy_aws_loadbalancer && var.deploy_rancher_istio && (length(var.connect_hostnames_from_alb_to_istio) > 0)
  can_connect_nginx_to_argocd = var.deploy_aws_loadbalancer && var.deploy_argocd
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
  version          = "4.4.0"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name = "controller.config.use-forwarded-headers"
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
    name = var.connect_hostnames_from_alb_ing_prefix != "" ? "${var.connect_hostnames_from_alb_ing_prefix}-nginx" : "ing-nginx"
    namespace = "ingress-nginx"

    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = var.loadbalancer_name
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/group.name" = "external"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
    }
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

resource "kubernetes_ingress_v1" "alb_ingress_connect_istio" {
  count = local.can_connect_alb_to_istio ? 1 : 0
  lifecycle {
    ignore_changes = [metadata["*cattle*"]]
  }
  wait_for_load_balancer = true
  metadata {
    name = var.connect_hostnames_from_alb_ing_prefix != "" ? "${var.connect_hostnames_from_alb_ing_prefix}-istio" : "ing-istio"
    namespace = "istio-system"

    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = var.loadbalancer_name
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/group.name" = "external"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
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

resource "helm_release" "argocd" {
  count            = var.deploy_argocd ? 1 : 0
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
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
  depends_on = [
    kubernetes_ingress_v1.alb_ingress_connect_nginx
  ]

}

# TODO: implement grpc
resource "kubernetes_ingress_v1" "nginx_ingress_connect_argocd" {
  count = local.can_connect_nginx_to_argocd ? 1 : 0
  lifecycle {
    ignore_changes = [metadata["*cattle*"]]
  }
  metadata {
    name = "argocd-server"
    namespace = "argocd"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.argocd_ingress_host
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.ingress_nginx,
    helm_release.argocd,
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

resource "kubectl_manifest" "argocd_bootstrapper_application" {
  count      = var.deploy_argocd ? 1 : 0
  yaml_body = yamlencode({
    apiVersion: "argoproj.io/v1alpha1"
    kind: "Application"
    metadata: {
      name: "argo-bootstrapper"
      namespace: "argocd"
    }
    spec: {
      project: "default"
      source: {
        repoURL: "https://github.com/kloia/ArgoCD-EKS-Bootstrapper.git"
        targetRevision: "HEAD"
        path: "helm"
        helm: {
          values: yamlencode({
            certManger: {
              enable: false
            }
            metricsServer: {
              enable: false
            }
            rancher: {
              enable: var.deploy_rancher
              values: {
                hostname: {
                  value: var.rancher_hostname
                }
              }
            }
            rancherMonitoringCrd: {
              enable: var.deploy_rancher_istio
            }
            rancherMonitoring: {
              enable: var.deploy_rancher_istio
            }
            rancherIstio: {
              enable: var.deploy_rancher_istio
            }
          })
        }
      }
      destination: {
        server: "https://kubernetes.default.svc"
        namespace: "argocd"
      }
      syncPolicy: {
        automated: {}
      }
    }
  })
  depends_on = [helm_release.argocd]
}
