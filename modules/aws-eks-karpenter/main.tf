// Karpenter infra resources and IRSA

locals {
  environment = var.environment
}

module "karpenter" {

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//modules/karpenter?ref=v20.31.0"

  cluster_name = "${local.environment}-eks"

  create = var.deploy_karpenter

  # Pod Identity
  create_pod_identity_association = true
  namespace                       = var.karpenter_namespace
  service_account                 = var.karpenter_service_account

  create_iam_role      = true
  create_node_iam_role = true

  enable_v1_permissions = var.enable_karpenter_v1_permissions

  node_iam_role_additional_policies = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

}

# resource "aws_iam_service_linked_role" "karpenter" {
#   aws_service_name = "spot.amazonaws.com"
# }
