output "serviceAccountARN" {
  description = "Service account"
  value       = kubernetes_service_account.service-account
}

output "appliedEKSCluster" {
  description = "Applied EKS cluster"
  value       = var.cluster_name
}

output "load_balancer_hostname" {
  description = "Load balancer Hostname"
  value       = kubernetes_ingress_v1.alb_ingress_connect_nginx.0.status.0.load_balancer.0.ingress.0.hostname
}

output "internal_load_balancer_hostname" {
  description = "Internal load balancer Hostname"
  value       = var.enable_internal_alb ? kubernetes_ingress_v1.alb_ingress_connect_nginx_internal.0.status.0.load_balancer.0.ingress.0.hostname : null
}