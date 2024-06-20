provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

module "event-rule" {
  source = "./../"

  name        = "event-rule"
  environment = "test"
  label_order = ["environment", "name"]

  description         = "Event Rule."
  schedule_expression = "cron(0/5 * * * ? *)"

  target_id      = "test"
  arn            = "arn:aws:lambda:eu-west-1:${data.aws_caller_identity.current.account_id}:function:hello_world_lambda"
  input_template = "\"<instance> is in state <status>\""
  input_paths = {
    instance = "$.detail.instance",
    status   = "$.detail.status",
  }

}
