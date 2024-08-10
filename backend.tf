terraform {
  backend "s3" {
    bucket         = "dhoondlai-state-tf"
    encrypt        = true
    region         = "us-east-1"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
  }
}
