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

variable "cilium_ipam_mode" {
  description = "IPAM mode of cilium"
  type        = string
  default     = "cluster-pool"
}

variable "cilium_ipam_IPv4CIDR" {
  description = "Cilium IPv4 CIDR"
  type        = string
}

variable "deploy_cilium" {
  description = "Deploy Cilium CNI flag"
  type        = bool
  default     = false
}

variable "deploy_rancher" {
  description = "Deploy Rancher flag"
  type = bool
  default = false
}

variable "rancher_hostname" {
  description = "Rancher Hostname"
  type = string
}

variable "deploy_rancher_istio" {
  description = "Deploy Ranchers' flavor of Istio flag"
  type        = bool
  default     = false
}

variable "connect_hostnames_from_alb_ing_prefix" {
  description = "Prefix to give ingress names when connecting alb hostnames"
  type = string
  default = "ing-{servicename}"
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