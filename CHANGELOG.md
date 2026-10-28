# Changelog

## [0.9.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.8.0...aws-rds-aurora-v0.9.0) (2026-10-28)


### Features

* **aws-rds-aurora:** tag the KMS key the module creates ([#392](https://github.com/kloia/platform-modules/issues/392)) ([6d28d76](https://github.com/kloia/platform-modules/commit/6d28d762f760ecb3c0a3d98aa15175d85272f5a0))

## [0.8.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.7.0...aws-rds-aurora-v0.8.0) (2026-10-19)


### Features

* **aws-rds-aurora:** support importing an existing cluster ([#376](https://github.com/kloia/platform-modules/issues/376)) ([ead6b0d](https://github.com/kloia/platform-modules/commit/ead6b0d484f03daa82604a7004e5bcac9b8ce939))

## [0.7.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.6.0...aws-rds-aurora-v0.7.0) (2026-10-16)


### Features

* **aws-rds-aurora:** make cluster-level Performance Insights configurable ([#373](https://github.com/kloia/platform-modules/issues/373)) ([b502293](https://github.com/kloia/platform-modules/commit/b5022935857262d0ac159877f4ec2198f21d2b5c))

## [0.6.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.5.0...aws-rds-aurora-v0.6.0) (2026-04-02)


### ⚠ BREAKING CHANGES

* aws_security_group_rule.cidr_ingress replaced with aws_vpc_security_group_ingress_rule using for_each. Existing deployments must perform state migration when upgrading:   1. terragrunt state rm 'aws_security_group_rule.cidr_ingress[0]' 2. terragrunt import 'aws_vpc_security_group_ingress_rule.cidr_ingress["<cidr>"]' <sgr-id> for each CIDR

### Bug Fixes

* aurora postgres compatibility and sql server variable defaults ([#311](https://github.com/kloia/platform-modules/issues/311)) ([aca6e07](https://github.com/kloia/platform-modules/commit/aca6e0775fd95171b9168ea163b704538f3f5542))

## [0.5.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.4.0...aws-rds-aurora-v0.5.0) (2024-07-08)


### Features

* Rds read replica ([#244](https://github.com/kloia/platform-modules/issues/244)) ([9a91151](https://github.com/kloia/platform-modules/commit/9a9115197db0da18930c229ac950db8e725b1ee4))
* Rds read replica ([#246](https://github.com/kloia/platform-modules/issues/246)) ([3828478](https://github.com/kloia/platform-modules/commit/3828478f1c5c713b7d56f7754e932a5ecdf344d4))

## [0.4.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.3.0...aws-rds-aurora-v0.4.0) (2024-05-23)


### ⚠ BREAKING CHANGES

* **rds-aurora:** needs apply method to be supplied for all parameter groups

### Features

* **rds-aurora:** add apply method ([#227](https://github.com/kloia/platform-modules/issues/227)) ([1aee7e3](https://github.com/kloia/platform-modules/commit/1aee7e391dee949c13636f532ac68c5e7286bbeb))

## [0.3.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.2.0...aws-rds-aurora-v0.3.0) (2024-05-17)


### Features

* Rds sql server ssrs ([#225](https://github.com/kloia/platform-modules/issues/225)) ([608cd3f](https://github.com/kloia/platform-modules/commit/608cd3f6ebc32b37e423879b0012bd980f0dc794))

## [0.2.0](https://github.com/kloia/platform-modules/compare/aws-rds-aurora-v0.1.0...aws-rds-aurora-v0.2.0) (2024-05-17)


### Features

* enable ssrs for sql server ([#223](https://github.com/kloia/platform-modules/issues/223)) ([4bc7faf](https://github.com/kloia/platform-modules/commit/4bc7faf232cdc6ad6c483b7ece125ba985d5964b))

## 0.1.0 (2024-05-10)


### Features

* import previous modules ([#153](https://github.com/kloia/platform-modules/issues/153)) ([126a74f](https://github.com/kloia/platform-modules/commit/126a74f8430ca971e61740f72de776dee210bb55))
