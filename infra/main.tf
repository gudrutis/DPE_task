
provider "aws" { 
  region = "us-west-2"
}

resource "aws_s3_bucket" "data_lake" {
  bucket = "zm-test-my-datalake-bucket-sakdhsakdhskd"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}


