provider "aws" {
  region = var.primary_region
}

variable "primary_region" {
  default     = "eu-west-1"
  type        = string
  description = "You can use as primary region for the AWS provider where this redis will be provisioned"
}
#####
# VPC and subnets
#####
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#####
# Elasticache Redis
#####
module "redis" {
  source = "../../"

  name_prefix        = "redis-clustered-example"
  num_cache_clusters = 2
  node_type          = "cache.m5.large"


  cluster_mode_enabled    = true
  replicas_per_node_group = 1
  num_node_groups         = 2

  engine_version           = "6.x"
  port                     = 6379
  maintenance_window       = "mon:03:00-mon:04:00"
  snapshot_window          = "04:00-06:00"
  snapshot_retention_limit = 7

  automatic_failover_enabled = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = "1234567890asdfghjkl"

  apply_immediately = true
  family            = "redis6.x"
  description       = "Test elasticache redis."

  subnet_ids = data.aws_subnets.all.ids
  vpc_id     = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  parameter = [
    {
      name  = "repl-backlog-size"
      value = "16384"
    }
  ]

  tags = {
    Project = "Test"
  }
}
