terraform {
  required_version = "~> 0.11.1"
}

provider "aws" {}

data "aws_caller_identity" "creds" {}
output "aws_account_id" {
  value = "${data.aws_caller_identity.creds.account_id}"
}
