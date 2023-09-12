# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "aft" {
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory"
  # Required Vars
  ct_management_account_id    = "112546318254"
  log_archive_account_id      = "673139683440"
  audit_account_id            = "297004248658"
  aft_management_account_id   = "546630717355"
  ct_home_region              = "eu-west-1"
  tf_backend_secondary_region = "eu-west-3"
}

module "infra_test_account" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "awsinfratest@inatech.onmicrosoft.com"
    AccountName               = "infrustructure-test"
    ManagedOrganizationalUnit = module.ou.ou_name
    SSOUserEmail              = "awsaccounts@inatech.onmicrosoft.com"
    SSOUserFirstName          = "Arun"
    SSOUserLastName           = "Kumar"
  }

  account_tags = {
    "ABC:Owner"       = "awsinfratest@inatech.onmicrosoft.com"
    "ABC:Division"    = "ENT"
    "ABC:Environment" = "Test"
    "ABC:CostCenter"  = "123456"
    "ABC:Vended"      = "true"
    "ABC:DivCode"     = "102"
    "ABC:BUCode"      = "ABC003"
    "ABC:Project"     = "Inatech-Infrustructure"
  }


  change_management_parameters = {
    change_requested_by = "AWS Control Tower Lab"
    change_reason       = "Inatech Account Creation with AWS Control Tower Account Factory for Terraform (AFT)"
  }

  account_customizations_name = "infrustructure-test"

  depends_on = [ module.infra_ou ]
}

module "infra_prod_account" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "awsinfratest@inatech.onmicrosoft.com"
    AccountName               = "infrustructure-test"
    ManagedOrganizationalUnit = module.ou.ou_name
    SSOUserEmail              = "awsaccounts@inatech.onmicrosoft.com"
    SSOUserFirstName          = "Arun"
    SSOUserLastName           = "Kumar"
  }

  account_tags = {
    "ABC:Owner"       = "awsinfratest@inatech.onmicrosoft.com"
    "ABC:Division"    = "ENT"
    "ABC:Environment" = "Test"
    "ABC:CostCenter"  = "123456"
    "ABC:Vended"      = "true"
    "ABC:DivCode"     = "102"
    "ABC:BUCode"      = "ABC003"
    "ABC:Project"     = "Inatech-Infrustructure"
  }


  change_management_parameters = {
    change_requested_by = "AWS Control Tower Lab"
    change_reason       = "Inatech Account Creation with AWS Control Tower Account Factory for Terraform (AFT)"
  }

  account_customizations_name = "infrustructure-test"

  depends_on = [ module.infra_ou ]
}

module "infra_ou" {
  source = "./modules/organizational-unit"
  ou_name = "infrastructure"
}