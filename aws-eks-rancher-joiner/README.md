# AWS EKS Rancher Joiner

Module for joining downstream EKS clusters to when,
without the use of the Rancher terraform provider.

**IMPORTANT:** Joiner module is meant to be used together with
[aws-eks-rancher-importer](https://github.com/kloia/platform-modules/tree/main/aws-eks-rancher-importer),
with two separate applies.

## Dependencies
- [aws-eks-rancher-importer](https://github.com/kloia/platform-modules/tree/main/aws-eks-rancher-importer)
- Available Rancher installation on upstream EKS cluster
- Upstream EKS Cluster connection information stored on Parameter Store, valid Role ARN to assume
- Downstream EKS Cluster connection

## Critical Providers

- Kubernetes provider, aliased to `upstream`

## Variables

Joiner module is dependent on having upstream connection information stored on AWS SSM Parameter Store, and
downstream connection information being readily available (through .tfvars, terraform_remote_state data resources, or wrappers like terragrunt)

| name                              | description                                              |
|-----------------------------------|----------------------------------------------------------|
| downstream_cluster_name           | Name of the existing downstream cluster                  |
| downstream_cluster_endpoint       | Endpoint of the downstream cluster                       |
| downstream_cluster_ca_cert        | Certificate Authority of the downstream cluster          |
| downstream_assume_role_arn        | Assume role arn for downstream cluster access            |
| upstream_cluster_name_ssm_key     | SSM Key pointing to existing upstream cluster name       |
| upstream_cluster_endpoint_ssm_key | SSM Key pointing to the endpoint of the upstream cluster |
| upstream_cluster_ca_cert_ssm_key  | SSM Key pointing to the CA of the upstream cluster       |
| upstream_assume_role_arn          | ARN of the Role to assume for upstream cluster access    |

## Usage

1. **Apply aws-eks-rancher-importer module**
   
    This will create the appropriate CRD that declares the Cluster definition on upstream.
    
    **If the cluster has already been joined to Rancher**, make sure to `terraform import` the following kubernetes resource,
    with the correct downstream cluster name.
    ```terraform
    resource "kubernetes_manifest" "cluster_provisioning" {
        provider = kubernetes.upstream

        manifest = {
            apiVersion = "provisioning.cattle.io/v1"
            kind       = "Cluster"
            metadata = {
            # TODO: namespace can be non-default
                namespace = "fleet-default"
                name      = var.downstream_cluster_name
            }
            # The empty spec has been lifted straight from
            # Rancher's UI when importing an existing cluster.
            spec = {
                localClusterAuthEndpoint = {}
            }
        }

        wait {
            fields = {
                "status.clusterName" = "*"
            }
        }
    }
    ```

2. **Apply aws-eks-rancher-joiner module**

   This will fetch the Rancher generated join manifest (a Rancher Agent setup manifest)
   from the upstream cluster, and apply it to the downstream.

   If downstream has already been joined to the upstream and the terraform state is up-to-date,
   it will not try to re-join the cluster.

   When importing already joined clusters to terraform, there is a chance terraform can re-apply agent setup
   manifest, which may result in restart of the Rancher agent. This behaviour has not been
   verified yet.