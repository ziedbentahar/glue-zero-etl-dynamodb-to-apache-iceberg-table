resource "aws_s3_bucket" "wg" {
  bucket        = "${var.application}-${var.environment}-athena-spill-bucket"
  force_destroy = true
}

resource "aws_athena_workgroup" "this" {
  name = "${var.application}-${var.environment}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.wg.bucket}/output/"
    }
  }
}
