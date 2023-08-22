resource "aws_cloudwatch_log_group" "this" {
  count = var.create ? 1 : 0

  name              = var.name
  name_prefix       = var.name_prefix
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id

  tags = var.tags
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = var.identifiers
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  count = var.create ? 1 : 0
  policy_name     = var.policy_name
  policy_document = data.aws_iam_policy_document.this.json
}