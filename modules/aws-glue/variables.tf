################################################################################
# Glue Catalog Database
################################################################################

variable "create_database" {
  description = "Whether to create the Glue catalog database."
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the Glue catalog database."
  type        = string
}

variable "database_description" {
  description = "Description of the Glue catalog database."
  type        = string
  default     = null
}

variable "catalog_id" {
  description = "AWS account ID of the Glue data catalog. Defaults to the current account."
  type        = string
  default     = null
}

variable "database_location_uri" {
  description = "Location of the database (e.g., an HDFS path)."
  type        = string
  default     = null
}

variable "database_parameters" {
  description = "Additional parameters for the Glue catalog database."
  type        = map(string)
  default     = {}
}

################################################################################
# Glue Crawler
################################################################################

variable "create_crawler" {
  description = "Whether to create the Glue crawler."
  type        = bool
  default     = true
}

variable "crawler_name" {
  description = "Name of the Glue crawler."
  type        = string
  default     = null
}

variable "crawler_role_arn" {
  description = "IAM role ARN that the crawler uses to access S3 and Glue."
  type        = string
  default     = null
}

variable "crawler_description" {
  description = "Description of the Glue crawler."
  type        = string
  default     = null
}

variable "crawler_schedule" {
  description = "Cron expression for the crawler schedule (e.g., 'cron(0 12 * * ? *)'). Omit for on-demand."
  type        = string
  default     = null
}

variable "crawler_table_prefix" {
  description = "Prefix for table names created by the crawler."
  type        = string
  default     = null
}

variable "crawler_classifiers" {
  description = "List of custom classifier names to associate with the crawler."
  type        = list(string)
  default     = []
}

variable "crawler_configuration" {
  description = "JSON string of Glue crawler configuration (e.g., grouping behavior)."
  type        = string
  default     = null
}

variable "s3_targets" {
  description = "List of S3 target configurations for the crawler."
  type = list(object({
    path                = string
    exclusions          = optional(list(string))
    connection_name     = optional(string)
    event_queue_arn     = optional(string)
    dlq_event_queue_arn = optional(string)
    sample_size         = optional(number)
  }))
  default = []
}

variable "schema_change_policy" {
  description = "Behavior when the crawler discovers a changed schema. update_behavior: UPDATE_IN_DATABASE or LOG. delete_behavior: DELETE_FROM_DATABASE, LOG, or DEPRECATE_IN_DATABASE."
  type = object({
    update_behavior = optional(string)
    delete_behavior = optional(string)
  })
  default = {}
}

variable "recrawl_policy" {
  description = "Recrawl behavior. recrawl_behavior: CRAWL_EVERYTHING, CRAWL_NEW_FOLDERS_ONLY, or CRAWL_EVENT_MODE."
  type = object({
    recrawl_behavior = optional(string)
  })
  default = {}
}

################################################################################
# Common
################################################################################

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
