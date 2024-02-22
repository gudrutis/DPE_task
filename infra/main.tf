resource "aws_s3_bucket" "lake_raw" {
  bucket = "${var.project_name}-lake-raw"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_object" "debt" {
  bucket = aws_s3_bucket.lake_raw.id
  key    = "debt"
  acl    = "private"
  source = "../data/municipal_debt.csv"
}

resource "aws_s3_object" "expenses" {
  bucket = aws_s3_bucket.lake_raw.id
  key    = "expenses"
  acl    = "private"
  source = "../data/Vilnius_council_expenses.csv"
}
