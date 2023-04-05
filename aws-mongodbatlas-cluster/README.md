# terraform-aws-mongodbatlas-cluster
Terraform module which creates a MongoDB Atlas cluster on AWS

These types of resources are supported:
* [Project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project)
* [Cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster)
* [Teams](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/team)
* [Whitelists](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_whitelist.html)
* [Network Peering](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_peering.html)

## Terraform versions

Terraform versions >=0.12 are supported
   
## Usage

```hcl
module "atlas_cluster" {
  source = "./terraform-aws-mongodbatlas-cluster"

  project_name = "my-project"
  org_id = "5edf67f9b9b528996228111"

  teams = {
    Devops: {
      users: ["example@mail.io", "user@mail.io"]
      role: "GROUP_OWNER"
    },
    DevTeam: {
      users: ["developer@mail.io",]
      role: "GROUP_READ_ONLY"
    }
  }

  white_lists = {
    "example comment": "10.0.0.1/32",
    "second example": "10.10.10.8/32"
  }

  region = "EU_WEST_1"

  cluster_name = "MyCluster"

  instance_type = "M30"
  mongodb_major_ver = 4.2
  cluster_type = "REPLICASET"
  num_shards = 1
  replication_specs_region_configs = [
    {
      region_name     = "EU-WEST-1"
      electable_nodes = 2
      priority        = 7
      read_only_nodes = 0
    },
    {
      region_name     = "EU-WEST-2"
      electable_nodes = 1
      priority        = 6
      read_only_nodes = 0
    }
  ]
  cloud_backup = true

}
```
## Prerequisites
* [MongoDB Cloud account](https://www.mongodb.com/cloud)
* [MongoDB Atlas Organization](https://cloud.mongodb.com/v2#/preferences/organizations/create)
* [MongoDB Atlas API key](https://www.terraform.io/docs/providers/mongodbatlas/index.html)

#### Manual tasks:

* Configure the API key before applying the module
* Get your MongoDB Atlas Organization ID from the UI

#### Create Teams:
In case you want to create Teams and associate them with the project, users must be added in advance and making sure they have accepted the invitation.
Users who have not accepted an invitation to join the organization cannot be added as team members. 

## VPC Peering
The following information is required:
* [Access to AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
* VPC ID
* [AWS account ID](https://docs.aws.amazon.com/general/latest/gr/acct-identifiers.html)
* Region
* [Routable cidr block](https://www.terraform.io/docs/providers/mongodbatlas/r/network_peering.html#route_table_cidr_block)

You can add them manually, or through other Terraform resources, and pass it to the module via ```vpc_peer``` variable:
```hcl
  vpc_peer = {
    vpc_peer1 : {
      aws_account_id : "020201234877"
      region : "eu-west-1"
      vpc_id : "vpc-0240c8a47312svc3e"
      route_table_cidr_block : "172.16.0.0/16"
    },
    vpc_peer2 : {
      aws_account_id : "0205432147877"
      region : "eu-central-1"
      vpc_id : "vpc-0f0dd82430bhv0e1a"
      route_table_cidr_block : "172.17.0.0/16"
    }
  }
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 1.4.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 1.4.5 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_cluster.cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster) | resource |
| [mongodbatlas_database_user.admin](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [mongodbatlas_network_peering.mongo_peer](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_peering) | resource |
| [mongodbatlas_project.project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project) | resource |
| [mongodbatlas_project_ip_access_list.whitelists](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [mongodbatlas_team.team](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/team) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [mongodbatlas_project.project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_scaling_disk_gb_enabled"></a> [auto\_scaling\_disk\_gb\_enabled](#input\_auto\_scaling\_disk\_gb\_enabled) | Indicating if disk auto-scaling is enabled | `bool` | `true` | no |
| <a name="input_cloud_backup"></a> [cloud\_backup](#input\_cloud\_backup) | Indicating if the cluster uses Cloud Backup for backups | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The cluster name | `string` | n/a | yes |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | The MongoDB Atlas cluster type - SHARDED/REPLICASET/GEOSHARDED | `string` | n/a | yes |
| <a name="input_create_mongodbatlas_project"></a> [create\_mongodbatlas\_project](#input\_create\_mongodbatlas\_project) | Create mongoDB atlas project flag | `bool` | `false` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Capacity,in gigabytes,of the host’s root volume | `number` | `null` | no |
| <a name="input_encryption_at_rest_provider"></a> [encryption\_at\_rest\_provider](#input\_encryption\_at\_rest\_provider) | Possible values are AWS, GCP, AZURE or NONE | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The Atlas instance-type name | `string` | n/a | yes |
| <a name="input_mongodb_major_ver"></a> [mongodb\_major\_ver](#input\_mongodb\_major\_ver) | The MongoDB cluster major version | `number` | n/a | yes |
| <a name="input_num_shards"></a> [num\_shards](#input\_num\_shards) | number of shards | `number` | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | The ID of the Atlas organization you want to create the project within | `string` | n/a | yes |
| <a name="input_pit_enabled"></a> [pit\_enabled](#input\_pit\_enabled) | Indicating if the cluster uses Continuous Cloud Backup, if set to true - cloud\_backup must also be set to true | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project you want to create | `string` | n/a | yes |
| <a name="input_provider_disk_iops"></a> [provider\_disk\_iops](#input\_provider\_disk\_iops) | The maximum IOPS the system can perform | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region-name that the cluster will be deployed on | `string` | n/a | yes |
| <a name="input_replication_specs_region_configs"></a> [replication\_specs\_region\_configs](#input\_replication\_specs\_region\_configs) | Region configs for replication specs | `list(any)` | n/a | yes |
| <a name="input_teams"></a> [teams](#input\_teams) | An object that contains all the groups that should be created in the project | `map(any)` | `{}` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | STANDARD or PROVISIONED for IOPS higher than the default instance IOPS | `string` | `"STANDARD"` | no |
| <a name="input_vpc_peer"></a> [vpc\_peer](#input\_vpc\_peer) | An object that contains all VPC peering requests from the cluster to AWS VPC's | `map(any)` | `{}` | no |
| <a name="input_white_lists"></a> [white\_lists](#input\_white\_lists) | An object that contains all the network white-lists that should be created in the project | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Mongo Atlas cluster name |
| <a name="output_connection_strings"></a> [connection\_strings](#output\_connection\_strings) | Set of connection strings that your applications use to connect to this cluster |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The Network Peering Container ID |
| <a name="output_database_admin_password"></a> [database\_admin\_password](#output\_database\_admin\_password) | Database Admin password |
| <a name="output_database_admin_username"></a> [database\_admin\_username](#output\_database\_admin\_username) | Database Admin username |
| <a name="output_mongo_db_version"></a> [mongo\_db\_version](#output\_mongo\_db\_version) | Version of MongoDB the cluster runs, in major-version.minor-version format |
| <a name="output_mongo_uri"></a> [mongo\_uri](#output\_mongo\_uri) | Base connection string for the cluster |
| <a name="output_mongo_uri_updated"></a> [mongo\_uri\_updated](#output\_mongo\_uri\_updated) | Lists when the connection string was last updated |
| <a name="output_mongo_uri_with_options"></a> [mongo\_uri\_with\_options](#output\_mongo\_uri\_with\_options) | connection string for connecting to the Atlas cluster. Includes the replicaSet, ssl, and authSource query parameters in the connection string with values appropriate for the cluster |
| <a name="output_paused"></a> [paused](#output\_paused) | Flag that indicates whether the cluster is paused or not |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Mongoatlas project ID |
| <a name="output_srv_address"></a> [srv\_address](#output\_srv\_address) | Connection string for connecting to the Atlas cluster. The +srv modifier forces the connection to use TLS/SSL |
| <a name="output_state_name"></a> [state\_name](#output\_state\_name) | Current state of the cluster |
| <a name="output_vpc_peering_ids"></a> [vpc\_peering\_ids](#output\_vpc\_peering\_ids) | Mongoatlas VPC Peering IDs |
<!-- END_TF_DOCS -->