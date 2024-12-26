data "aws_iam_policy_document" "glue_resource_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        aws_iam_role.manage_zero_etl_integration_role.arn
      ]
    }

    actions = [
      "glue:CreateInboundIntegration",
    ]

    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/${aws_glue_catalog_database.this.name}",
    ]

    # condition {
    #   test     = "StringLike"
    #   variable = "aws:SourceArn"
    #   values   = [data.aws_dynamodb_table.this.arn]
    # }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = [
      "glue:AuthorizeInboundIntegration"
    ]

    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/${aws_glue_catalog_database.this.name}",
    ]

    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:SourceArn"
    #   values   = [data.aws_dynamodb_table.this.arn]
    # }
  }

  depends_on = [
    aws_iam_role.manage_zero_etl_integration_role,
    aws_lambda_function.manage_zero_etl_integration_fn
  ]
}


resource "aws_glue_resource_policy" "this" {
  policy = data.aws_iam_policy_document.glue_resource_policy.json
}


