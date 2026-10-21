# aws-guardduty-detector-features

Sets the status of GuardDuty protection plans (`aws_guardduty_detector_feature`) on an
existing detector. Use it next to the module or account setup that creates the detector,
for example `aws-guardduty-master` or an organization's delegated administrator.

- Pass `detector_id`, or leave it null to look up the detector of the current account and
  Region. The lookup fails at plan time while no detector exists yet, so pass the ID when
  the detector is created in the same apply.
- Declare every plan you want to control, including the ones to keep `DISABLED`. A
  detector created through the API turns some plans on by default, and a plan left out is
  not managed.
- In an organization, a plan the delegated administrator auto-enables for **all** members
  is switched back on for the account. Set the organization's auto-enable for that plan to
  new accounts only before disabling it here, otherwise the plan drifts.
- If the detector also manages S3 protection through the legacy `datasources` block (as
  `aws-guardduty-master` does with `s3_protection_enabled`), leave `S3_DATA_EVENTS` out
  of `features` so the two do not fight.

## Usage

```hcl
module "guardduty_features" {
  source = "git::https://github.com/kloia/platform-modules.git?ref=module/aws-guardduty-detector-features/v0.1.0"

  detector_id = module.guardduty.guardduty_detector.id

  features = {
    RDS_LOGIN_EVENTS       = { status = "ENABLED" }
    EKS_AUDIT_LOGS         = { status = "DISABLED" }
    EBS_MALWARE_PROTECTION = { status = "DISABLED" }
    LAMBDA_NETWORK_LOGS    = { status = "DISABLED" }
    RUNTIME_MONITORING = {
      status = "ENABLED"
      additional_configuration = {
        ECS_FARGATE_AGENT_MANAGEMENT = "ENABLED"
        EKS_ADDON_MANAGEMENT         = "DISABLED"
        EC2_AGENT_MANAGEMENT         = "DISABLED"
      }
    }
  }
}
```

Requires AWS provider 5.20 or later, the first release with `aws_guardduty_detector_feature`.
