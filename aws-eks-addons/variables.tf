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

variable "enable_shield_advanced_protection_from_alb_to_istio" {
  description = "Setup Shield for traffic from ALB to Istio"
  type        = bool
  default     = false
}


# karpenter

variable "deploy_karpenter" {
  description = "Deploy controller flag"
  default = false
  type = bool
}

variable "oidc_provider_arn" {
  description = "oidc provider arn"
  default = ""
  type = string
}


variable "eks_managed_node_groups_iam_role_arn" {
  description = "iam role arn"
  default = ""
  type = string
}

variable "stateful_capacity_types" { # +
  description = "instance types"
  default = ["on-demand"]
  type = list(string)
}


variable "stateless_capacity_types" {
  description = "instance types"
  default = "[\"spot\"]"
  type = string
}

variable "stateful_instance_types" { 
  description = "instance types"
  default = ["r6a.xlarge", "r6a.2xlarge", "r6a.4xlarge","r6a.9xlarge"]
  type = list(string)
}

variable "stateless_instance_types" {
  description = "instance types"
  default = "[\"c5n.xlarge\", \"c5n.2xlarge\", \"c5n.4xlarge\",\"c5n.9xlarge\"]"
  type = string
}

variable "stateful_instance_zones" { 
  description = "instance types"
  default = ["eu-west-1a"]
  type = list(string)
}

variable "stateless_instance_zones" {
  description = "instance types"
  default = "[\"eu-west-1a\"]"
  type = string
}

variable "stateful_arch_types" {
  description = "instance types"
  default = ["amd64"]
  type = list(string)
}

variable "stateless_arch_types" {
  description = "instance types"
  default = "[\"amd64\"]"
  type = string
}

variable "stateful_application_toleration_value" {
  description = "stateful application tolerance value for scheduling"
  default = "stateful-application"
  type = string
}

variable "stateful_total_cpu_limit" {
  description = "cpu limit"
  default = "400"
  type = string
}

variable "stateless_total_cpu_limit" {
  description = "cpu limit"
  default = "400"
  type = string
}

variable "karpenter_node_template_volume_size" {
  description = "Node Volume Size"
  default = "40Gi"
  type = string
}

variable "karpenter_node_template_volume_type" {
  description = "Node Volume Type"
  default = "gp3"
  type = string
}

variable "karpenter_node_template_volume_iops" {
  description = "Node Volume IOPS"
  default = "3000"
  type = string
}

variable "karpenter_node_template_delete_on_termination" {
  description = "Termination deletion policy check"
  default = true
  type = bool
}

variable "karpenter_node_template_throughput" {
  description = "Node Throughput"
  default = "125"
  type = string
}