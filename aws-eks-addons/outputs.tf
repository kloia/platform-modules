output "serviceAccountARN" {
  description = "Service account"
  value = kubernetes_service_account.service-account
}

output "appliedEKSCluster" {
    description = "Applied EKS cluster"
    value = var.cluster_name
}

output "load_balancer_hostname" {
  description = "Load balancer Hostname"
  # TODO: This might be invalid after var.connect_alb_to_nginx option
  value = kubernetes_ingress_v1.alb_ingress_connect_nginx.0.status.0.load_balancer.0.ingress.0.hostname
}