output "time_zone_id" {
  description = "Time zone Atlas uses for hour_of_day in this project."
  value       = mongodbatlas_maintenance_window.this.time_zone_id
}
