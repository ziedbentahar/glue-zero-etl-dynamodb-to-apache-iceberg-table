resource "aws_iam_role" "manage_zero_etl_integration_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "manage_zero_etl_integration_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          aws_iam_role.integration_role.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:CreateIntegration",
          "glue:CreateIntegrationResourceProperty",
          "glue:CreateIntegrationTableProperties",
          "glue:DeleteIntegration",
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter"
        ]
        Resource = [
          "*",
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "manage_zero_etl_integration_attachement" {
  role       = aws_iam_role.manage_zero_etl_integration_role.name
  policy_arn = aws_iam_policy.manage_zero_etl_integration_policy.arn
}

data "archive_file" "manage_zero_etl_integration_archive" {
  type        = "zip"
  source_dir  = var.manage_zero_etl_integration.dist_dir
  output_path = "${path.root}/.terraform/tmp/lambda-dist-zips/${var.manage_zero_etl_integration.name}.zip"
}

resource "aws_lambda_function" "manage_zero_etl_integration_fn" {
  function_name    = "${var.application}-${var.environment}-${var.manage_zero_etl_integration.name}"
  filename         = data.archive_file.manage_zero_etl_integration_archive.output_path
  role             = aws_iam_role.manage_zero_etl_integration_role.arn
  handler          = var.manage_zero_etl_integration.handler
  source_code_hash = filebase64sha256("${data.archive_file.manage_zero_etl_integration_archive.output_path}")
  runtime          = "nodejs22.x"
  memory_size      = "256"
  architectures    = ["arm64"]

  logging_config {
    system_log_level      = "INFO"
    application_log_level = "INFO"
    log_format            = "JSON"
  }
}

resource "aws_cloudwatch_log_group" "manage_zero_etl_integration_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.manage_zero_etl_integration_fn.function_name}"
  retention_in_days = "3"
}
