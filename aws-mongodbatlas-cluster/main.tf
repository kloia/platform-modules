# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

locals {
  network_containers = {for container in data.mongodbatlas_network_containers.aws_containers.results : lower(replace(container.region_name,"_","-")) => {"id" = container.id,"atlas_cidr_block"=container.atlas_cidr_block}}
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ATLAS PROJECT THAT THE CLUSTER WILL RUN INSIDE
# ---------------------------------------------------------------------------------------------------------------------

data "mongodbatlas_project" "project" {
  count  = var.create_mongodbatlas_project ? 0 : 1
  name = var.project_name
}

resource "mongodbatlas_project" "project" {
  count  = var.create_mongodbatlas_project ? 1 : 0
  name   = var.project_name
  org_id = var.org_id

  #Associate teams and privileges if passed, if not - run with an empty object
  dynamic "teams" {
    for_each = var.teams

    content {
      team_id    = mongodbatlas_team.team[teams.key].team_id
      role_names = [teams.value.role]
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE TEAMS FROM **EXISTING USERS**
# ---------------------------------------------------------------------------------------------------------------------

resource "mongodbatlas_team" "team" {
  for_each = var.teams

  org_id    = var.org_id
  name      = each.key
  usernames = each.value.users
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE ADMIN USER
# ---------------------------------------------------------------------------------------------------------------------

resource "random_password" "password" {
  length  = 14
  special = false
  upper   = false
}

resource "mongodbatlas_database_user" "admin" {

  project_id    = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  username      = "${var.cluster_name}-admin"
  password = random_password.password.result
  auth_database_name = "admin"

  roles {
    role_name = "atlasAdmin"
    database_name = "admin"
  }
  scopes {
    name = var.cluster_name
    type = "CLUSTER"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE NETWORK WHITE-LISTS FOR ACCESSING THE PROJECT
# ---------------------------------------------------------------------------------------------------------------------

#Optionall, if no variable is passed, the loop will run on an empty object.

resource "mongodbatlas_project_ip_access_list" "whitelists_with_cidr" {
  for_each = var.white_lists_with_cidr

  project_id = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  comment    = each.key
  cidr_block = each.value
}

resource "mongodbatlas_project_ip_access_list" "whitelists_with_aws_sg" {
  for_each = var.white_lists_with_security_group

  project_id = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  comment    = each.key
  aws_security_group = each.value
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE MONGODB ATLAS CLUSTER IN THE PROJECT
# ---------------------------------------------------------------------------------------------------------------------

resource "mongodbatlas_cluster" "cluster" {
  project_id                   = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  name                         = var.cluster_name
  disk_size_gb                 = var.disk_size_gb
  num_shards                   = var.num_shards
  cloud_backup                 = var.cloud_backup
  cluster_type                 = var.cluster_type
  provider_name                = local.cloud_provider
  provider_instance_size_name  = var.instance_type
  mongo_db_major_version       = var.mongodb_major_ver
  pit_enabled                  = var.pit_enabled
  auto_scaling_disk_gb_enabled = var.auto_scaling_disk_gb_enabled
  provider_volume_type         = var.volume_type
  provider_disk_iops           = var.provider_disk_iops
  encryption_at_rest_provider  = var.encryption_at_rest_provider


  replication_specs {
    num_shards = var.num_shards
    dynamic "regions_config" {
      for_each = var.replication_specs_region_configs
      content {
        region_name     = lookup(regions_config.value, "region_name")
        electable_nodes = lookup(regions_config.value, "electable_nodes")
        priority        = lookup(regions_config.value, "priority")
        read_only_nodes = lookup(regions_config.value, "read_only_nodes")
      }
    }

  }
  depends_on = [
    mongodbatlas_custom_dns_configuration_cluster_aws.aws,
    mongodbatlas_encryption_at_rest.aws_encryption,
  ]

}

# ---------------------------------------------------------------------------------------------------------------------
# Encryption at Rest
# ---------------------------------------------------------------------------------------------------------------------


resource "mongodbatlas_encryption_at_rest" "aws_encryption" {
  count = var.encryption_at_rest_provider != "" ? 1 : 0
  project_id = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id

  aws_kms_config {
    enabled                = true
    customer_master_key_id = lookup(var.aws_kms_config,"customer_master_key_id")
    region                 = lookup(var.aws_kms_config,"region")
    role_id                = lookup(var.aws_kms_config,"atlas_role_id")
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AWS PEER REQUESTS TO AWS VPC
# ---------------------------------------------------------------------------------------------------------------------


resource "mongodbatlas_network_peering" "mongo_peer" {
  for_each = var.vpc_peer

  accepter_region_name   = each.value.accepter_region
  project_id             = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  container_id           = lookup(local.network_containers[each.value.atlas_region],"id",null)
  provider_name          = local.cloud_provider
  route_table_cidr_block = each.value.route_table_cidr_block
  vpc_id                 = each.value.vpc_id
  aws_account_id         = each.value.aws_account_id
}

data "mongodbatlas_network_containers" "aws_containers" {
  project_id     = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  provider_name  = "AWS"

  depends_on = [ mongodbatlas_cluster.cluster ]
}


resource "mongodbatlas_custom_dns_configuration_cluster_aws" "aws" {
  project_id    = var.create_mongodbatlas_project ? mongodbatlas_project.project[0].id : data.mongodbatlas_project.project[0].id
  enabled = true
}
