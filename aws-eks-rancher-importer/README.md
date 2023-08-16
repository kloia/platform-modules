# AWS EKS Rancher Importer

Module for declaring _generic_ imports of existing EKS clusters in Rancher,
without the use of the Rancher terraform provider.

**IMPORTANT:** Importer module is meant to be used together with
[aws-eks-rancher-joiner](https://github.com/kloia/platform-modules/tree/main/aws-eks-rancher-joiner),
with two separate applies.

## Dependencies
- [aws-eks-rancher-joiner](https://github.com/kloia/platform-modules/tree/main/aws-eks-rancher-joiner)
- Available Rancher installation on upstream EKS cluster
- Upstream EKS Cluster connection information stored on Parameter Store, valid Role ARN to assume

## Critical Providers

- Kubernetes provider, aliased to `upstream`

## Variables

Importer module is dependent on having clusters' connection information stored on AWS SSM Parameter Store.

| name                              | description                                                                                                                              |
|-----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| rancher_cluster_name              | Name of the rancher cluster resource representing the downstream cluster name. If not set, will default to `var.downstream_cluster_name` |
| downstream_cluster_name           | Name of the existing downstream cluster                                                                                                  |
| upstream_cluster_name_ssm_key     | SSM Key pointing to existing upstream cluster name                                                                                       |
| upstream_cluster_endpoint_ssm_key | SSM Key pointing to the endpoint of the upstream cluster                                                                                 |
| upstream_cluster_ca_cert_ssm_key  | SSM Key pointing to the CA of the upstream cluster                                                                                       |
| upstream_assume_role_arn          | ARN of the Role to assume for upstream cluster access                                                                                    |

## Usage

1. **Apply aws-eks-rancher-importer module**
   
    This will create the appropriate Custom Resource that declares the Cluster definition on **upstream**.

    **If the cluster has already been joined to Rancher**, make sure to `terraform import` import the kubernetes resource.

    ```
    $ terraform import kubernetes_manifest.cluster_provisioning "apiVersion=provisioning.cattle.io/v1,kind=Cluster,namespace=fleet-default,name={ClusterName}"
    ```

    If you are using the module source code directly, the terraform resource id is `kubernetes_manifest.cluster_provisioning`,
    if not, prefix it with `module.<your_module_name>.kubernetes_manifest.cluster_provisioning`

2. **Apply aws-eks-rancher-joiner module**

   This will fetch the Rancher generated join manifest (a Rancher Agent setup manifest)
   from the upstream cluster, and apply it to the **downstream**.

   If downstream has already been joined to the upstream and the terraform state is up-to-date,
   it will not try to re-join the cluster.

   When importing already joined clusters to terraform, there is a chance terraform can re-apply agent setup
   manifest, which may result in restart of the Rancher agent. This behaviour has not been
   verified yet.
