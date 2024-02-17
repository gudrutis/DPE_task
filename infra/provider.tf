terraform {
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}