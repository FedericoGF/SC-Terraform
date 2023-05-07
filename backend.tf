terraform {
  backend "s3" {
    encrypt = true
    bucket = "s3-bucket23ob"
    dynamodb_table = "terraform-lock-table"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}