variable "project_name" {
  type        = string
  description = "Atlas project name, looked up by name, so the caller needs no dependency on the unit that creates the project."
}

variable "day_of_week" {
  type        = number
  description = "Day the window starts: 1 = Sunday, 2 = Monday, ... 7 = Saturday."
}

variable "hour_of_day" {
  type        = number
  description = "Hour (0-23) the window starts, in the project's time zone."
}

variable "auto_defer_once_enabled" {
  type        = bool
  default     = null
  description = "Defer all scheduled maintenance by one week, once. Null leaves the Atlas setting unmanaged."
}

variable "protected_hours" {
  type = object({
    start_hour_of_day = number
    end_hour_of_day   = number
  })
  default     = null
  description = "Hours (project time zone) with no standard updates. Set it to the live value: leaving it out may clear protected hours already configured in the UI."
}
