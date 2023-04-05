# AWS EKS Terraform module

Terraform module which creates a service account and deploys aws-load-balancer-controller attached to that service account into the cluster.

### External Documentation

## Available Features
Creates an service account and deploys aws-load-balancer-controller helm chart.

## Usage

```hcl

inputs = {
    loadbalancer_irsa_arn = "${dependency.eks-irsa.outputs.iam_role_arn}"
    vpc_id = "${dependency.eks-vpc.outputs.vpc_id}"
    cluster_region = "${local.region}"
    cluster_name = "${dependency.eks.outputs.cluster_name}"
    cluster_endpoint = "${dependency.eks.outputs.cluster_endpoint}"
    cluster_ca_cert= "${dependency.eks.outputs.cluster_certificate_authority_data}"
    image_repository = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
    // regional list of the image repositories
    // https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
}

dependency "eks" {
    config_path = "../eks-cluster"
    mock_outputs = {
        cluster_name = "known after apply"
    }
}

dependency "eks-irsa" {
    config_path = "../eks-irsa"
    mock_outputs = {
        iam_role_arn = "known after apply"
    }
}

dependency "eks-vpc" {
    config_path = "../../vpc"
    mock_outputs = {
        vpc_id = "known after apply"
    }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.9 |
| <a name="requirement_version"></a> [terragrunt](#requirement\_terragrunt) | >= 0.38.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |
| <a name="provider_helm"></a> [tls](#provider\_tls) | >= 2.6.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_service_account.service-account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [helm_release.lb](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
