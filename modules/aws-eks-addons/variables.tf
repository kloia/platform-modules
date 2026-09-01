variable "loadbalancer_irsa_arn" {
  description = "Role ARN of the IRSA"
  default     = ""
  type        = string
}

variable "service_common_iam_role_arn" {
  description = "Role ARN of the IRSA"
  default     = ""
  type        = string
}

variable "crossplane_irsa_arn" {
  description = "Role ARN of the IRSA"
  default     = ""
  type        = string

}

variable "vpc_id" {
  description = "Vpc ID "
  type        = string
  default     = ""
}

variable "loadbalancer_name" {
  description = "Load balancer name "
  type        = string
  default     = ""
}

variable "internal_loadbalancer_name" {
  description = "Internal load balancer name "
  type        = string
  default     = ""
}

variable "argocd_ssl_redirect_annotation" {
  description = "Argocd ssl redirect configuration "
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM Certificate arn for ingress"
  type        = string
}

variable "image_repository" {
  description = "image registry"
  default     = "012345678901.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = ""
  type        = string

}

variable "cluster_region" {
  description = "region of the EKS cluster"
  default     = "eu-west-1"
  type        = string
}

variable "eso_iam_role_arn" {
  type        = string
  description = "External secrets operator role arn for service account."
}

variable "argocd_iam_role_arn" {
  description = "Argocd IAM Role ARN"
  type        = string
  default     = ""
}

variable "argocd_ingress_host" {
  description = "Argocd host path for ingress"
  type        = string
  default     = ""
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  default     = ""
  type        = string

}

variable "cluster_ca_cert" {
  description = "Certificate Authority of the EKS cluster"
  default     = ""
  type        = string

}

variable "assume_role_arn" {
  description = "Assume role arn for cluster access"
  type        = string
}

variable "deploy_aws_loadbalancer" {
  description = "Deploy AWS Loadbalancer flag"
  type        = bool
  default     = false
}

variable "deploy_argocd" {
  description = "Create ArgoCD resources flag"
  type        = bool
  default     = false
}

variable "deploy_crossplane" {
  description = "Deploy Crossplane flag"
  type        = bool
  default     = false
}

variable "deploy_external_secrets" {
  description = "Deploy External Secrets flag"
  type        = bool
  default     = false
}

variable "deploy_trivy" {
  description = "Deploy Trivy flag"
  type        = bool
  default     = false
}

variable "deploy_metrics_server" {
  description = "Deploy Rancher flag"
  type        = bool
  default     = false
}

variable "deploy_cert_manager" {
  description = "Deploy Rancher flag"
  type        = bool
  default     = false
}

variable "deploy_rancher" {
  description = "Deploy Rancher flag"
  type        = bool
  default     = false
}

variable "rancher_hostname" {
  description = "Rancher Hostname"
  type        = string
  default     = ""
}

variable "deploy_rancher_monitoring" {
  description = "Deploy Rancher Monitoring and it's CRDs"
  type        = bool
  default     = false
}

variable "deploy_rancher_istio" {
  description = "Deploy Ranchers' flavor of Istio flag"
  type        = bool
  default     = false
}

variable "connect_hostnames_from_alb_ing_prefix" {
  description = "Prefix to give ingress names when connecting alb hostnames"
  type        = string
  default     = "ing-servicename"
}

variable "connect_hostnames_from_alb_to_nginx" {
  description = "Incoming ALB connections with the matching hostnames will be handled internally by nginx"
  type        = list(string)
  default     = []
}

variable "connect_hostnames_from_alb_to_istio" {
  description = "Incoming ALB connections with the matching hostnames will be handled internally by istio"
  type        = list(string)
  default     = []
}

variable "enable_shield_advanced_protection_from_alb_to_istio" {
  description = "Setup Shield for traffic from ALB to Istio"
  type        = bool
  default     = false
}

variable "enable_internal_alb" {
  description = "Whether to create an internal ALB"
  type        = bool
  default     = false
}

variable "connect_hostnames_from_alb_internal_ing_prefix" {
  description = "Prefix to give internal ingress names when connecting alb hostnames"
  type        = string
  default     = "internal-ing-servicename"
}

variable "connect_hostnames_from_internal_alb_to_nginx" {
  description = "Incoming internal ALB connections with the matching hostnames will be handled internally by nginx"
  type        = list(string)
  default     = []
}

variable "deploy_argo_workflow" {
  description = "Deploy Argo Workflow flag"
  type        = bool
  default     = false
}


variable "argo_workflow_ingress_host" {
  description = "Argo workflow hostname for ingress"
  type        = string
  default     = ""
}


variable "argo_workflow_extra_args" {
  description = "Argo workflow extraArgs "
  type        = list(any)
  default     = []
}
# karpenter

variable "deploy_karpenter" {
  description = "Deploy controller flag"
  default     = true
  type        = bool
}

variable "oidc_provider_arn" {
  description = "oidc provider arn"
  default     = ""
  type        = string
}


variable "eks_managed_node_groups_iam_role_arn" {
  description = "iam role arn"
  default     = ""
  type        = string
}

variable "stateful_capacity_types" { # +
  description = "instance types"
  default     = ["on-demand"]
  type        = list(string)
}

variable "stateless_capacity_types" {
  description = "instance types"
  default     = ["spot"]
  type        = list(string)
}

variable "stateless_windows_capacity_types" {
  description = "instance types"
  default     = ["spot"]
  type        = list(string)
}

variable "stateful_instance_types" {
  description = "instance types"
  default     = ["r6a.xlarge", "r6a.2xlarge", "r6a.4xlarge", "r6a.9xlarge"]
  type        = list(string)
}

variable "stateful_windows_instance_types" {
  description = "instance types"
  default     = ["r6a.xlarge", "r6a.2xlarge", "r6a.4xlarge", "r6a.9xlarge"]
  type        = list(string)
}

variable "stateless_instance_types" {
  description = "instance types"
  default     = ["c5n.xlarge", "c5n.2xlarge", "c5n.4xlarge", "c5n.9xlarge"]
  type        = list(string)
}

variable "stateless_windows_instance_types" {
  description = "instance types"
  default     = ["c5n.xlarge", "c5n.2xlarge", "c5n.4xlarge", "c5n.9xlarge"]
  type        = list(string)
}

variable "stateful_instance_zones" {
  description = "instance types"
  default     = ["eu-west-1a"]
  type        = list(string)
}

variable "stateless_instance_zones" {
  description = "instance types"
  default     = ["eu-west-1a"]
  type        = list(string)
}

variable "stateful_arch_types" {
  description = "instance types"
  default     = ["amd64"]
  type        = list(string)
}

variable "stateless_arch_types" {
  description = "instance types"
  default     = ["amd64"]
  type        = list(string)
}

variable "stateless_windows_arch_types" {
  description = "instance types"
  default     = ["amd64"]
  type        = list(string)
}

variable "stateful_application_toleration_value" {
  description = "stateful application tolerance value for scheduling"
  default     = "stateful-application"
  type        = string
}

variable "stateful_total_cpu_limit" {
  description = "cpu limit"
  default     = 400
  type        = number
}

variable "stateless_total_cpu_limit" {
  description = "cpu limit"
  default     = 400
  type        = number
}

variable "karpenter_node_template_volume_size" {
  description = "Node Volume Size"
  default     = "40Gi"
  type        = string
}

variable "karpenter_node_template_volume_type" {
  description = "Node Volume Type"
  default     = "gp3"
  type        = string
}

variable "karpenter_node_template_volume_iops" {
  description = "Node Volume IOPS"
  default     = "3000"
  type        = string
}

variable "karpenter_node_template_delete_on_termination" {
  description = "Termination deletion policy check"
  default     = true
  type        = bool
}

variable "karpenter_node_template_throughput" {
  description = "Node Throughput"
  default     = "125"
  type        = string
}

variable "enable_sso" {
  default     = false
  description = "Creation control logic of AWS SSO integration at ArgoCD"
}


variable "enable_template_file" {
  default     = false
  description = "Creation control logic of Template file"
}

variable "current_environment" {
  default     = ""
  type        = string
  description = "Environment name"
}

variable "sso_ca_data_network_account" {
  default     = ""
  description = "Value of the CA data for AWS SSO integration at ArgoCD"
}

variable "sso_url_network_account" {
  default     = ""
  description = "Value of the Single Sign-On URL for AWS SSO."
}

variable "sso_callback_url" {
  default     = ""
  description = "value of the callback url for AWS SSO integration at ArgoCD"
}

variable "gitops_url" {
  description = "url of the argocd"
  default     = "https://gitops.platform.mycompany.com"
}

variable "aws_lb_controller_version" {
  description = "AWS load balancer controller version"
  default     = "1.6.1"
}

variable "karpenter_version" {
  description = "Karpenter version"
  default     = "v0.31.1"
}

variable "karpenter_windows_support" {
  default     = false
  description = "Karpenter Windows Container Support"
}

variable "deploy_rancher_logging" {
  default     = false
  description = "value of the rancher logging"
}

variable "rancher_logging_fluentd_memory_limit" {
  default     = "3000Mi"
  description = "value of the rancher logging fluentd memory limit"
}

variable "rancher_logging_fluentd_cpu_limit" {
  default     = "3000m"
  description = "value of the rancher logging fluentd cpu limit"
}


variable "rancher_logging_fluentd_memory_request" {
  default     = "2000Mi"
  description = "value of the rancher logging fluentd memory request"

}

variable "rancher_logging_fluentd_cpu_request" {
  default     = "2000m"
  description = "value of the rancher logging fluentd cpu request"
}


variable "deploy_karpenter_crds" {
  default     = true
  description = "deploy provisioners and node template"
}

variable "waf_acl_arn" {
  description = "wafv2 acl arn"
  default     = ""
  type        = string
}

variable "internal_waf_acl_arn" {
  description = "wafv2 acl arn for internal alb"
  default     = ""
  type        = string
}

variable "deploy_adot_collector" {
  default     = false
  description = "enable the ADOT collector"
}

variable "adot_collector_role" {
  description = "ADOT collector IAM role ARN"
  default     = "arn:aws:iam::123456789012:role/adot-role"
  type        = string
}

variable "adot_collector_namespace" {
  description = "ADOT collector namespace name"
  default     = "opentelemetry-operator-system"
  type        = string
}

variable "adot_collector_service_account" {
  description = "ADOT collector service account name"
  default     = "opentelemetry-operator-system"
  type        = string
}

variable "adot_collector_hostname" {
  description = "ADOT collector IAM role ARN"
  default     = "trace.example.com"
  type        = string
}

variable "nginx_version" {
  description = "Ingress NGINX Helm chart version"
  default     = "4.4.0"
}
variable "metrics_server_version" {
  description = "Metrics Server version"
  default     = null
  type        = string
}

variable "trivy_version" {
  description = "Trivy version"
  default     = null
  type        = string
}

variable "cert_manager_version" {
  description = "Cert Manager version"
  default     = null
  type        = string
}

variable "rancher_version" {
  description = "Rancher version"
  default     = null
  type        = string
}

variable "rancher_monitoring_crd_version" {
  description = "Rancher Monitoring CRD version"
  default     = null
  type        = string
}

variable "rancher_monitoring_version" {
  description = "Rancher Monitoring version"
  default     = null
  type        = string
}

variable "rancher_istio_version" {
  description = "Rancher Istio version"
  default     = null
  type        = string
}

variable "argo_workflow_version" {
  description = "Argo Workflow version"
  default     = null
  type        = string
}

variable "rancher_logging_version" {
  description = "Rancher Logging version"
  default     = null
  type        = string
}

variable "argocd_version" {
  description = "ArgoCD version"
  default     = null
  type        = string
}

variable "enable_notification" {
  description = "Enable ArgoCD notifications integration (Slack)"
  type        = bool
  default     = false
}

variable "notification_slack_token" {
  default     = ""
  description = "Value of the Slack Token for ArgoCD Notification"
}

variable "alb_tags" {
  description = "Extra AWS tags applied to the ALBs created for the nginx ingress connectors. Rendered into the alb.ingress.kubernetes.io/tags annotation on both the external and internal connector ingresses. Empty by default (no extra tags)."
  type        = map(string)
  default     = {}
}

variable "nginx_controller_pod_labels" {
  description = "Extra pod labels applied to the ingress-nginx controller pods (set as controller.podLabels in the ingress-nginx Helm release). Empty by default (no extra labels)."
  type        = map(string)
  default     = {}
}
# ---------------------------------------------------------------------------
# Cost-allocation pod labels for the remaining platform workloads.
#
# Same shape and default as nginx_controller_pod_labels above: an empty map
# means "set nothing", so every existing caller is unaffected. Each variable
# maps onto a value key that was verified against the chart version this module
# pins (see the comment on each one).
# ---------------------------------------------------------------------------

variable "aws_lb_controller_pod_labels" {
  description = "Extra pod labels applied to the aws-load-balancer-controller pods (set as podLabels in the aws-load-balancer-controller Helm release). Empty by default (no extra labels)."
  type        = map(string)
  default     = {}
}

variable "argocd_pod_labels" {
  description = <<-EOT
    Extra pod labels applied to every Argo CD component pod, set per component
    (controller.podLabels, server.podLabels, repoServer.podLabels,
    redis.podLabels, dex.podLabels, applicationSet.podLabels,
    notifications.podLabels). Empty by default (no extra labels).

    DO NOT pass `Name` here: the module stamps a per-component Name so each
    label set carries the name of the workload it lands on, which is what a
    cost-allocation Name has to be. Anything passed as Name is overwritten with:
      controller     -> argocd-application-controller
      server         -> argocd-server
      repoServer     -> argocd-repo-server
      redis          -> argocd-redis
      dex            -> argocd-dex-server
      applicationSet -> argocd-applicationset-controller
      notifications  -> argocd-notifications-controller

    global.podLabels is deliberately NOT used - it would put one Name on all
    seven components.
  EOT
  type        = map(string)
  default     = {}
}

variable "external_secrets_pod_labels" {
  description = <<-EOT
    Extra pod labels applied to the external-secrets controller, webhook and
    cert-controller pods (podLabels, webhook.podLabels and
    certController.podLabels). Empty by default (no extra labels).

    DO NOT pass `Name` here - as with argocd_pod_labels the module stamps a
    per-component Name and overwrites anything passed:
      (root)         -> external-secrets
      webhook        -> external-secrets-webhook
      certController -> external-secrets-cert-controller
  EOT
  type        = map(string)
  default     = {}
}

variable "karpenter_pod_labels" {
  description = "Extra pod labels applied to the Karpenter controller pods (set as podLabels in the karpenter Helm release). Only takes effect when deploy_karpenter is true. Empty by default (no extra labels)."
  type        = map(string)
  default     = {}
}

variable "metrics_server_values" {
  description = <<-EOT
    Free-form Helm values forwarded to the metrics-server Application that the
    ArgoCD bootstrapper renders (metricsServer.values in the argo-bootstrapper
    Helm values). Empty by default, which keeps the bootstrapper's own defaults.

    This is a REPLACEMENT, not a merge: whatever is passed here becomes the
    Application's entire values block. If the cluster already relies on values
    that were set outside Terraform (hostNetwork.enabled=true is a common one),
    those MUST be repeated here or they will be dropped on the next sync. Read
    the live values first:
      kubectl -n argocd get application metrics-server \
        -o jsonpath='{.spec.source.helm.values}'

    Example:
      metrics_server_values = {
        hostNetwork = { enabled = true }
        podLabels   = { Environment = "prod" }
      }
  EOT
  type        = any
  default     = {}
}

variable "rancher_logging_pod_labels" {
  description = <<-EOT
    Extra pod labels applied to the rancher-logging OPERATOR pods (set as
    podLabels in the rancher-logging chart values forwarded through the ArgoCD
    bootstrapper). Empty by default (no extra labels).

    This does NOT reach the fluentbit DaemonSet or the fluentd StatefulSet:
    those pods are created by the Logging operator from the Logging custom
    resource, and their labels live in spec.fluentbit.labels /
    spec.fluentd.labels on that CR, not in the chart values.
  EOT
  type        = map(string)
  default     = {}
}
