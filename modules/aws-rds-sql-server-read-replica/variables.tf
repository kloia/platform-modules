variable "name" {
  description = "Name used across resources created"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Random Password & Snapshot ID
################################################################################

variable "create_random_password" {
  description = "Determines whether to create random password for RDS primary cluster"
  type        = bool
  default     = false
}

variable "random_password_length" {
  description = "Length of random password to create. Defaults to `10`"
  type        = number
  default     = 10
}


################################################################################
# Replica
################################################################################

variable "allocated_storage" {
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster)"
  type        = number
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = null
}


variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = true
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = null
}

variable "master_password" {
  description = "Password for the master DB user. Note - when specifying a value here, 'create_random_password' should be set to `false`"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "root"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = null
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is `true`"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: `io1`, Default: `io1`"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"
  type        = list(string)
  default     = []
}


################################################################################
# Cluster Instance(s)
################################################################################

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
  default     = null
}

variable "instances_use_identifier_prefix" {
  description = "Determines whether cluster instance identifiers are used as prefixes"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = ""
}


################################################################################
# Enhanced Monitoring
################################################################################

variable "create_monitoring_role" {
  description = "Determines whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "Friendly name of the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether to use `iam_role_name` as is or create a unique name beginning with the `iam_role_name` as the prefix"
  type        = bool
  default     = false
}

variable "iam_role_description" {
  description = "Description of the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the monitoring role"
  type        = list(string)
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any policies the monitoring role has before destroying it"
  type        = bool
  default     = null
}

variable "monitoring_interval" {
  description = "Monitoring interval second"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "performance enablement "
  type        = bool
  default     = true
}

variable "logs_exports" {
  description = "Log exports"
  type        = list(string)
  default     = ["error"]
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
  type        = number
  default     = null
}

#############################
# Amazon RDS for SQL Server #
#############################

variable "rds_sql" {
  type        = bool
  description = "this is value to enable RDS SQL"
  default     = false
}

variable "custom_db_paramater_group_name" {
  type        = string
  description = "the paramater group name"
  default     = ""
}

variable "custom_db_option_group_name" {
  type        = string
  description = "the option group name"
  default     = ""
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Multi Availibity Zone"
}

variable "read_replica" {
  type        = bool
  default     = false
  description = "Read replica for RDS"
}

variable "db_group_name" {
  type        = string
  description = "DB parameter and option group name prefix"
  default = null
}

variable "option_group" {
  type = list(object({
    option_name = string
    option_rule_names = optional(list(object({
      rule_name         = string
      option_rule_value = any
    })))
  }))
  default = null
}

variable "parameter_group" {
  type = list(object({
    parameter_name         = string
    parameter_value        = any
    parameter_apply_method = string
  }))
  default = null
}

variable "enable_custom_option_group" {
  type        = bool
  default     = false
  description = "Custom Option Group Creation"
}

variable "enable_custom_parameter_group" {
  type        = bool
  default     = false
  description = "Custom Paramater Group Creation"
}

variable "max_allocated_storage" {
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster)"
  type        = number
  default     = null
}

variable "option_group_engine_version" {
  type        = string
  default     = "16.00"
  description = "Option Group Major engine version"
}

variable "option_name" {
  type        = string
  description = "Option name for without option settings of ptions"
  default = ""
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = true
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines whether to create security group for RDS cluster"
  type        = bool
  default     = true
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
  default     = ""
}

variable "allowed_security_groups" {
  description = "A list of Security Group ID's to allow access to"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)
  default     = []
}

variable "security_group_egress_rules" {
  description = "A map of security group egress rule definitions to add to the security group created"
  type        = map(any)
  default     = {}
}

variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

################################################################################
# DB Subnet Group
################################################################################

variable "subnet_id_names" {
  description = "name of subnet ID's"
  type        = string
  default     = "*"
}

################################################################################
# DB Parameter Group
################################################################################


variable "create_db_parameter_group" {
  description = "Determines whether a DB parameter should be created or use existing"
  type        = bool
  default     = false
}

variable "db_parameter_group_use_name_prefix" {
  description = "Determines whether the DB parameter group name is used as a prefix"
  type        = bool
  default     = true
}

variable "db_parameter_group_description" {
  description = "The description of the DB parameter group. Defaults to \"Managed by Terraform\""
  type        = string
  default     = null
}

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

variable "db_parameter_group_parameters" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default     = []
}

variable "kms_key_id" {
  description = "The key ID of the KMS key"
  default     = null
}

variable "kms_multi_region" {
  description = "Determine whether the KMS key is multi region support"
  type        = bool
  default     = false
}
