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


## part 3 - IAM users
locals {
  users = ["salesuser", "customersuser"]
  policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
  ]
}

module "iam_salesuser" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  name = "salesuser"
  # set random password and output
  password_length = 16
  password_reset_required = false
  # Optional parameters like 'path', 'force_destroy', etc., can be specified here.
}

module "iam_customersuser" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  name = "customersuser"
  # set random password and output
  password_length = 16
  password_reset_required = false
  # Optional parameters like 'path', 'force_destroy', etc., can be specified here.
}

# attach policies to iam_saleuser
resource "aws_iam_user_policy_attachment" "salesuser" {
  count = length(local.policies)
  user = module.iam_salesuser.iam_user_name
  policy_arn = local.policies[count.index]
}

# attach policies to iam_customersuser
resource "aws_iam_user_policy_attachment" "customersuser" {
  count = length(local.policies)
  user = module.iam_customersuser.iam_user_name
  policy_arn = local.policies[count.index]
}

# get iam_customersuser password from module output
output "customersuser_password" {
  value = "Password for `customersuser`: ${module.iam_customersuser.iam_user_login_profile_password}"
  sensitive = true
}

# get iam_salesuser password from module output
output "iam_salesuser_password" {
  value = "Password for `salesuser`: ${module.iam_salesuser.iam_user_login_profile_password}"
  sensitive = true
  # can format this output to be more user friendly

}

## part 4 - Custom Role for Glue
resource "aws_iam_role" "lake_crawler_role" {
  name        = "lake-crawler-role"
  description = "Allows Glue to call AWS services on your behalf to crawl data in S3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lake_crawler_role_power_user" {
  role       = aws_iam_role.lake_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

## part 5 - example data 
resource "aws_s3_object" "sales" {
  bucket = aws_s3_bucket.lake_raw.id
  key    = "data/sales/sales.csv"
  acl    = "private"
  source = "../data/sales.csv"
}

resource "aws_s3_object" "customers" {
  bucket = aws_s3_bucket.lake_raw.id
  key    = "data/customers/customers.csv"
  acl    = "private"
  source = "../data/customers.csv"
}
