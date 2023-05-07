terraform {
  backend "s3" {
    encrypt = true
    bucket = "s3-bucketfg"
    dynamodb_table = "terraform-lock-table.s3"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}






