# aws-access-analyzer

Creates an IAM Access Analyzer external-access analyzer and, optionally, archive rules for
findings that are expected. The analyzer reports resources (IAM roles, S3 buckets, KMS keys,
secrets, queues, snapshots and others) whose policies grant access to principals outside the
zone of trust: the account for `ACCOUNT`, the organization for `ORGANIZATION`.

- Access Analyzer is regional: create one analyzer per Region you use.
- `ORGANIZATION` works only from the management account or a delegated administrator, and
  needs IAM Access Analyzer trusted access in AWS Organizations. Enable it once, outside this
  module (`aws organizations enable-aws-service-access --service-principal
  access-analyzer.amazonaws.com`); managing the organization's service-access principals in
  Terraform replaces the whole list.
- The analyzer only reads policies and reports. It does not change or block access.
- External-access findings have no charge. Unused-access analysis is a separate, paid analyzer
  type and is out of scope.
- An archive rule archives new and existing findings that match all of its filters. Use it
  for access that is intended, such as a role your support partner assumes.

## Usage

```hcl
module "access_analyzer" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-access-analyzer/v0.1.0"

  analyzer_name = "organization"
  type          = "ORGANIZATION"

  archive_rules = {
    # Placeholder account ID: a partner account allowed to assume roles.
    partner-access-roles = [
      { criteria = "principal.AWS", eq = ["111122223333"] },
      { criteria = "resourceType", eq = ["AWS::IAM::Role"] },
    ]
  }
}
```
