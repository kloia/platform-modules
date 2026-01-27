output "helm_releases" {
  description = "Helm releases output"
  value       = helm_release.release
  sensitive   = true
}

output "kubectl_manifest_files_output" {
  description = "kubectl_manifest.file_manifest output"
  value       = kubectl_manifest.file_manifest
  sensitive   = true
}
