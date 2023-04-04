# Platform-Modules
### Kloia Platform Development Terraform Modules

This repository contains Terraform modules for building and managing AWS infrastructure for platform development.

Usage
Each module can be used by referencing its source code in your own Terraform code. For example, to use the vpc module, you can include the following code in your Terraform configuration:

```
module "vpc" {
  source = "git::https://github.com/kloia/platform-modules//vpc?ref=main"
  name   = "my-vpc"
  cidr   = "10.0.0.0/16"
}
```

This will create a VPC in the specified CIDR range with the name "my-vpc". For more information on the parameters each module expects, see the module's README.md file.

### Current Modules
```
aws-acm
aws-alb-master
aws-api-gateway
aws-apigateway-v2-master
aws-centralized-logging
aws-cloudfront
aws-cloudtrail
aws-cloudtrail-s3-bucket
aws-cloudwatch
aws-cloudwatch-event-rule-master
aws-dynamodb-dax
aws-dynamodb-table
aws-ecr
aws-ecs
aws-ecs-load-balancer
aws-ecs-service
aws-ecs-task-definition
aws-eks
aws-eks-addons
aws-elasticache-redis
aws-elasticsearch
aws-guardduty-master
aws-iam
aws-kms
aws-lambda
aws-mongodbatlas-access
aws-mongodbatlas-auth
aws-mongodbatlas-cluster
aws-mongodbatlas-database-user
aws-msk-apache-kafka-cluster-master
aws-rds-aurora
aws-rds-global-cluster
aws-route53-health-check-main
aws-route53-records
aws-route53-zones
aws-s3
aws-secrets-manager
aws-security-group
aws-sns-master
aws-ssm-parameter-store
aws-vpc
aws-vpc-peering-requester
aws-waf
aws-waf-ip-set
aws-waf-regex-patternset
aww-vpc-peering-accepter
```

### License
This code is released under the MIT License. 


### Contribution 

You can fork the repository and contrib repo via pull-requests . Never hesitate and Community UP :smile: :heart: