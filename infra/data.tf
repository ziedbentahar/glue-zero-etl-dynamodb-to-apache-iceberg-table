data "aws_dynamodb_table" "this" {
  name = var.source_table
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
