variable "deploy_karpenter" {
  default = true
  type    = bool
}

variable "karpenter_namespace" {
  description = "Karpenter Namespace"
  type        = string
  default     = "karpenter"
}

variable "karpenter_service_account" {
  description = "Karpenter Service Account Name"
  type        = string
  default     = "karpenter"
}

variable "node_iam_role_arn" {
  description = "EKS Managed Node Group Role ARN"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_karpenter_v1_permissions" {
  description = "Enable Karpenter v1 permissions"
  type        = bool
  default     = false
  
}