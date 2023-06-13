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

variable "resful_alb_hostname" {
  description = "REST alb hostname"
  type        = string
}

variable "grpc_alb_hostname" {
  description = "GRPC alb hostname"
  type        = string
}

variable "deploy_aws_loadbalancer" {
  description = "Deploy AWS Loadbalancer flag"
  type        = bool
  default     = false
}

variable "deploy_ingress_nginx" {
  description = "Deploy ingress-nginx itself"
  type        = bool
  default     = true
}

variable "connect_alb_to_nginx" {
  description = "Create an ingress definition routing alb to ingress-nginx"
  type        = bool
  default     = true
}

variable "deploy_ingress_nginx_resources" {
  description = "Deploy Ingress Nginx resources"
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

variable "cilium_ipam_mode" {
  description = "IPAM mode of cilium"
  type        = string
  default     = "cluster-pool"
}

# TODO: Deprecate
variable "cilium_ipam_IPv4CIDR" {
  description = "Cilium IPv4 CIDR"
  type        = string
  default     = ""
}

variable "cilium_ipam_IPv4CIDRs" {
  description = "Cilium IPv4 CIDR"
  type        = list(string)
  default     = []
}

variable "deploy_cilium" {
  description = "Deploy Cilium CNI flag"
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
}

variable "argocd_bootstrapper_helm_parameters" {
  description = <<EOF
Helm Parameters to override the ArgoCD EKS Bootstrapper Values

Keep in mind, certain parameters like "rancher.enable" and "rancher.values.hostname" will be automatically
derived from other variables, such as "var.deploy_rancher" and "var.rancher_hostname" respectively.
Review the plan for conflicts.

EOF
  type        = list(object({ name = string, value = any }))
  default     = [
    {
      "name"  = "certManager.enable"
      "value" = "false"
    },
    {
      "name"  = "metricsServer.enable"
      "value" = "false"
    },
  ]
}