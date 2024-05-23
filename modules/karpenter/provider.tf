provider "aws" {
  assume_role {
    role_arn = var.provider_assume_role_arn
  }
  region = var.provider_region
}
