resource "aws_s3_bucket" "database_bucket" {
  bucket_prefix = "${var.application}-${var.environment}-database"
  force_destroy = true
}


resource "aws_glue_catalog_database" "this" {
  name         = replace("${var.application}${var.environment}db", "-", "")
  location_uri = "s3://${aws_s3_bucket.database_bucket.bucket}/"
}
