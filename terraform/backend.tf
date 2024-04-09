terraform {
  backend "s3" {
    bucket = "jar-terraform-state-backend"
    key = "terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "jar-terraform-state-lock-table"
  }
}
