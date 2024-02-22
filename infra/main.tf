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

# resource "aws_iam_user" "data_lake_user" {
#   name = "data_lake_user"
#   path = "/"
# }

# # AWS Glue Catalog Database
# resource "aws_glue_catalog_database" "data_lake_db" {
#   name = "data_lake_database"
# }

# # AWS Lake Formation Permissions
# resource "aws_lakeformation_permissions" "data_lake_permissions" {
#   principal       = aws_iam_user.data_lake_user.id
#   permissions     = ["ALL"]
#   permissions_with_grant_option = ["ALL"]
#   catalog_resource = false
#   data_location {
#     arn            = aws_s3_bucket.example.arn
#     catalog_id     = data.aws_caller_identity.current.account_id
#   }
# }

# # AWS Glue Crawler for S3 Data Lake
# resource "aws_glue_crawler" "s3_crawler" {
#   name          = "data-lake-crawler"
#   role          = "your-iam-role-arn-for-glue"
#   database_name = aws_glue_catalog_database.data_lake_db.name

#   s3_target {
#     path = aws_s3_bucket.data_lake.bucket
#   }
# }


variable "users" {
  default = ["salesuser", "customersuser"]
}

variable "policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
  ]
}

resource "aws_iam_user" "users" {
  for_each = toset(var.users)
  name     = each.value
}

resource "random_password" "passwords" {
  for_each = toset(var.users)
  length   = 16
  special  = true
}

resource "aws_iam_user_login_profile" "profiles" {
  for_each                = toset(var.users)
  user                    = each.value
  pgp_key                 = "keybase:someuser"
  password_reset_required = true
}

locals {
  user_policy_combinations = [
    for u in var.users : [
      for p in var.policies : {
        user = u
        policy = p
      }
    ]
  ]
  user_policy_map = { for idx, up in flatten(local.user_policy_combinations) : "${up.user}-${up.policy}" => up }
}

resource "aws_iam_user_policy_attachment" "policies" {
  for_each = local.user_policy_map
  user = each.value.user
  policy_arn = each.value.policy
}
  
# output "user_passwords" {
#   value = { for u in var.users : u => random_password.passwords[u].result }
#   sensitive = true
# }