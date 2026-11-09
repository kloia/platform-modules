terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# All values are placeholders. In a real unit these usually come from
# yamldecode(file("identity-center.yaml")), split over up to three units:
# permission sets, users and groups, assignments.
module "identity_center" {
  source = "../.."

  users = {
    "jane.doe" = {
      given_name  = "Jane"
      family_name = "Doe"
      email       = "jane.doe@example.com"
    }
    "john.roe" = {
      given_name   = "John"
      family_name  = "Roe"
      display_name = "John Roe (Ops)"
      email        = "john.roe@example.com"
    }
  }

  groups = {
    platform-admins = {
      description = "Platform administrators"
      members     = ["jane.doe", "john.roe", "sam.existing"]
    }
    auditors = {
      members = ["jane.doe"]
    }
  }

  permission_sets = {
    PlatformAdmin = {
      description         = "Administrator access"
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    ReadOnlyPlus = {
      description         = "Read only plus CloudWatch Logs queries"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      customer_managed_policies = [
        { name = "example-extra-read", path = "/" },
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["logs:StartQuery", "logs:GetQueryResults"]
          Resource = "*"
        }]
      })
      tags = { Purpose = "example" }
    }
  }

  account_assignments = [
    {
      principal_type      = "GROUP"
      principal_name      = "platform-admins"
      permission_set_name = "PlatformAdmin"
      account_ids         = ["111111111111", "222222222222"]
    },
    {
      principal_type      = "GROUP"
      principal_name      = "auditors"
      permission_set_name = "ReadOnlyPlus"
      account_ids         = ["111111111111"]
    },
    {
      principal_type      = "GROUP"
      principal_name      = "Example Control Tower Group"
      permission_set_name = "AWSAdministratorAccess"
      account_ids         = ["222222222222"]
    },
  ]

  existing_users           = ["sam.existing"]
  existing_groups          = ["Example Control Tower Group"]
  existing_permission_sets = ["AWSAdministratorAccess"]
}

output "identity_center" {
  value = {
    user_ids            = module.identity_center.user_ids
    group_ids           = module.identity_center.group_ids
    permission_set_arns = module.identity_center.permission_set_arns
  }
}
