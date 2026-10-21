output "detector_id" {
  description = "ID of the detector the features were applied to."
  value       = local.detector_id
}

output "features" {
  description = "Managed protection plans and their status."
  value       = { for name, f in aws_guardduty_detector_feature.this : name => f.status }
}
