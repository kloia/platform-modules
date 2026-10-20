# Atlas reads hour_of_day in the project's time zone (time_zone_id, set only in the
# Atlas Project Settings UI), not in UTC. Check that time zone before choosing
# hour_of_day. An Atlas maintenance window has no end time.
data "mongodbatlas_project" "this" {
  name = var.project_name
}

resource "mongodbatlas_maintenance_window" "this" {
  project_id              = data.mongodbatlas_project.this.id
  day_of_week             = var.day_of_week
  hour_of_day             = var.hour_of_day
  auto_defer_once_enabled = var.auto_defer_once_enabled

  dynamic "protected_hours" {
    for_each = var.protected_hours == null ? [] : [var.protected_hours]
    content {
      start_hour_of_day = protected_hours.value.start_hour_of_day
      end_hour_of_day   = protected_hours.value.end_hour_of_day
    }
  }
}
