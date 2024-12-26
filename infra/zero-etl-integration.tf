resource "aws_lambda_invocation" "manage_zero_etl_integration" {

  function_name = aws_lambda_function.manage_zero_etl_integration_fn.function_name
  input = jsonencode({
    integrationName = "${var.application}-${var.environment}-zero-etl-integration",
    sourceArn       = data.aws_dynamodb_table.this.arn,
    targetArn       = aws_glue_catalog_database.this.arn,
    roleArn         = aws_iam_role.integration_role.arn,
    tableConfig = {
      tableName = data.aws_dynamodb_table.this.name,
      partitionSpec = [
        {
          FieldName    = "orderDate",
          FunctionSpec = "day"
        }
      ],
      unnestSpec : "FULL"
    }

  })

  lifecycle_scope = "CRUD"

  depends_on = [aws_glue_resource_policy.this, aws_glue_catalog_database.this]

}
