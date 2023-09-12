provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::112546318254:role/AWSAFTExecution"
  }
  default_tags {
    tags = {
      managed_by = "AFT"
    }
  }
}