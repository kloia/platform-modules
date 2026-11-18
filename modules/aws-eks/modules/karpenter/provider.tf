provider "aws" {
  assume_role {
    role_arn     = var.provider_assume_role_arn
    session_name = var.provider_session_name
  }
  region = var.provider_region
}
