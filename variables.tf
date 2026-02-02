variable "eks_cluster_name" {
  description = "The name of the eks cluster"
  type        = string
}

variable "helm_releases" {
  description = "Map of Helm releases to install"
  type        = any
  default     = {}
}

variable "kubectl_manifest_files" {
  description = "The kubectl manifest file to apply"
  type        = any
  default     = {}
}
