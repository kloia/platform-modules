variable "loadbalancer_irsa_arn" {
  description = "Role ARN of the IRSA"
  default = ""
  type = string
}

variable "service_common_iam_role_arn" {
  description = "Role ARN of the IRSA"
  default = ""
  type = string
}

variable "crossplane_irsa_arn" {
  description = "Role ARN of the IRSA"
  default = ""
  type = string

}

variable "vpc_id" {
  description = "Vpc ID "
  type = string
  default = ""
}

variable "acm_certificate_arn"{
  description = "ACM Certificate arn for ingress"
  type = string
}

variable "image_repository" {
  description = "image registry"
  default = "012345678901.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
  type = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  default = ""
  type = string

}

variable "cluster_region" {
    description = "region of the EKS cluster"
    default = "eu-west-1"
    type = string
}

variable "eso_iam_role_arn"{
  type = string
  description = "External secrets operator role arn for service account."
}

variable "argocd_iam_role_arn"{
  description = "Argocd IAM Role ARN"
  type = string
  default = ""
}

variable "argocd_ingress_host"{
  description = "Argocd host path for ingress"
  type = string
  default = ""
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  default = ""
  type = string

}

variable "cluster_ca_cert" {
  description = "Certificate Authority of the EKS cluster"
  default = ""
  type = string

}

variable "assume_role_arn" {
  description = "Assume role arn for cluster access"
  type = string
}

variable "create_argocd_resources"{
  description = "Create ArgoCD resources flag"
  type = bool
  default = true
}

variable "resful_alb_hostname" {
  description = "REST alb hostname"
  type = string
}

variable "grpc_alb_hostname" {
  description = "GRPC alb hostname"
  type = string
}