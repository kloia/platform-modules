data "aws_caller_identity" "current" {}

# aws_ecr_repository creates the aws_ecr_repository resource
resource "aws_ecr_repository" "this" {
  count = var.create ? 1 : 0
  name  = var.ecr_repo_name

  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_pushing
  }

  tags = var.tags
}

 #ecs_ecr_read_perms defines the regular read and login perms for principals defined in var.allowed_read_principals
data "aws_iam_policy_document" "ecs_ecr_read_perms" {
  count = var.create ? 1 : 0

  statement {
    sid = "ECRREad"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    principals {
      identifiers = var.allowed_read_principals
      type        = "AWS"
    }
    condition  {
      test     = "StringLike"
      variable = "aws:PrincipalOrgID"
      values   = [var.organization_id]
    }
  }
}

# ecr_read_and_write_perms defines the ecr_read_and_write_perms for principals defined in var.allowed_write_principals
data "aws_iam_policy_document" "ecr_read_and_write_perms" {
  count = var.create ? 1 : 0

  # The previously created ecs_ecr_read_perms will be merged into this document.
  source_json = data.aws_iam_policy_document.ecs_ecr_read_perms[0].json

  statement {
    sid = "ECRWrite"

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
    ]

    principals {
      identifiers = var.allowed_write_principals
      type        = "AWS"
    }
    condition  {
      test     = "StringLike"
      variable = "aws:PrincipalOrgID"
      values   = [var.organization_id]
    }
  }
}

# aws_ecr_repository_policy defines the policy for the ECR repository
# when var.allowed_write_principals contains no principals, only the data.aws_iam_policy_document.ecs_ecr_read_perms.json will
# be used to populate the iam policy.
resource "aws_ecr_repository_policy" "this" {
  count      = var.create ? 1 : 0
  repository = aws_ecr_repository.this[0].name

  policy = length(var.allowed_write_principals) > 0 ? data.aws_iam_policy_document.ecr_read_and_write_perms[0].json : data.aws_iam_policy_document.ecs_ecr_read_perms[0].json
}


resource "aws_ecr_replication_configuration" "example" {
  replication_configuration {
    rule {
      destination {
        region      = var.secondary_region
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}