# Changelog

## [1.0.0](https://github.com/kloia/platform-modules/compare/aws-vpc-v0.1.0...aws-vpc-v1.0.0) (2026-01-21)


### ⚠ BREAKING CHANGES

* updated provider constraint to hashicorp/aws >= 6.0.0. This requires the following resource updates:
    - aws_eip: Removed deprecated  argument.
    - aws_nat_gateway: Updated logic to support regional nat gateway
    (default: zonal).

### Features

* upgrade to aws provider v6 ([#294](https://github.com/kloia/platform-modules/issues/294)) ([3cae6a7](https://github.com/kloia/platform-modules/commit/3cae6a7a2159445119bebb3f1be63325b047ed23))

## 0.1.0 (2024-05-10)


### Features

* import previous modules ([#153](https://github.com/kloia/platform-modules/issues/153)) ([126a74f](https://github.com/kloia/platform-modules/commit/126a74f8430ca971e61740f72de776dee210bb55))
