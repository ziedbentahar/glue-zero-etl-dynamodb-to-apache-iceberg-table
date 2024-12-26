resource "aws_ssm_parameter" "this" {
  name = "/${var.application}/${var.environment}/zero-etl"
  type = "String"
  value = jsonencode({
    targetArn       = aws_glue_catalog_database.this.arn,
    sourceArn       = data.aws_dynamodb_table.this.arn,
    targetBucketId  = aws_s3_bucket.database_bucket.id,
    roleArn         = aws_iam_role.integration_role.arn
    integrationName = "${var.application}-${var.environment}-zero-etl"
  })
}
