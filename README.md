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
aws-cognito-user-pool
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

## Code Quality

This project is using [pre-commits](https://pre-commit.com) to ensure the quality of the code.
You should install Python3.6 or newer together and run:
```bash
brew install pre-commit tflint tfsec terrascan
```
For more installation options visit the [pre-commits](https://pre-commit.com) and [terraform-hooks](https://github.com/antonbabenko/pre-commit-terraform#how-to-install).

This project is using [commitizen](https://commitizen-tools.github.io/commitizen/#about) to giving an easy to follow set of rules to create an explicit commit history that is meaningful to both a human being and a machine.

To comply with the rule, commit messages must begin one of the following:
- **build:** Changes that affect the build system or external dependencies (adding, removing, or upgrading dependencies).
- **chore:** A code change includes a technical or preventative maintenance task that is necessary for managing the product or the repository, but it is not tied to any specific feature or user story. For example, regenerating generated code that must be included in the repository could be a chore.
- **ci:** A code change makes changes to continuous integration or continuous delivery scripts or configuration files.
- **docs:** Documentation only changes.
- **feat:** A code change implements a new feature for the application.
- **fix:** A code change fixes a defect in the application.
- **perf:** A code change improves the performance of algorithms or general execution time of the product.
- **refactor:** A code change that neither fixes a bug nor adds a feature
- **revert:** A code change reverts one or more commits that were previously included in the product, but were accidentally merged or serious issues were discovered that required their removal from the main branch.
- **style:** A code change updates or reformats the style of the source code, but does not otherwise change the product implementation.
- **test:** Adding missing tests or correcting existing tests.
- **bump:** A commit about changing to new or specific version.

To turn on pre-commit checks for commit operations in git, run before commit your changes:
```bash
pre-commit install
```

Additionally, to turn on conventional commits pre-commit check for commit operations in git, run from root directory before commit your changes:
```bash
./scripts/commit-msg.sh
```

To run all checks on your staged files, run:
```bash
pre-commit run
```
To run all checks on all files, run:
```bash
pre-commit run --all-files
```

### License
This code is released under the MIT License.


### Contribution

You can fork the repository and contrib repo via pull-requests . Never hesitate and Community UP :smile: :heart: