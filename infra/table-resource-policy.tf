resource "aws_dynamodb_resource_policy" "this" {
  resource_arn = data.aws_dynamodb_table.this.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = [
          "dynamodb:ExportTableToPointInTime",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeExport"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          StringLike = {
            "aws:SourceArn" = "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:integration:*"
          }
        }
      }
    ]
  })
}
