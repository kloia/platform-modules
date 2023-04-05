################################################################################
# Global Cluster
################################################################################
resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.global_cluster_identifier
  engine                    = var.global_cluster_engine   
  engine_version            = var.global_cluster_engine_version    
  database_name             = var.global_cluster_database_name     
  storage_encrypted         = var.global_cluster_storage_encrypted 
}