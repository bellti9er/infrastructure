provider "aws" {
  region = "ap-northeast-2"

  # Terraform by default looks at the ~/.aws/credentials file 
  # for the aws access key and secret.
  # The profile config tells which profile credential
  # to look at in the aws credential file.
  profile = "bellti9er"
}

resource "aws_s3_bucket" "terraform_state_prod" {
  bucket = "bellti9er-tf-state-prod"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_prod_versioning" {
  bucket = aws_s3_bucket.terraform_state_prod.id

  versioning_configuration {
    status = "Enabled"
  }
}