resource "aws_iam_role_policy" "policy" {
  name = "mongodb_atlas_kms_policy"
  role = aws_iam_role.role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ],
        "Resource": [
          "${var.aws_kms_key_arn}"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "role" {
  name = "mongodb_atlas_kms_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${var.atlas_aws_account_arn}"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "${var.atlas_assumed_role_external_id}"
          }
        }
      }
    ]
  }
  EOF
}