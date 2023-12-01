data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "this" {
  for_each = toset(var.ecr_repo_names) 

  name  = each.value

  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_pushing
  }

  tags = var.tags
}

data "aws_iam_policy_document" "ecs_ecr_read_perms" {
  statement {
    sid = "ECRRead"

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

data "aws_iam_policy_document" "ecr_read_and_write_perms" {
  statement {
    sid = "ECRRead"

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

resource "aws_ecr_repository_policy" "this" {
  for_each = toset(var.ecr_repo_names) 

  repository = each.value

  policy = length(var.allowed_write_principals) > 0 ? data.aws_iam_policy_document.ecr_read_and_write_perms.json : data.aws_iam_policy_document.ecs_ecr_read_perms.json

  depends_on = [ aws_ecr_repository.this ]
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
