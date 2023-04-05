data "aws_iam_role" "DaxtoDynamoDBRole" {
    name = var.iam_role_name
}