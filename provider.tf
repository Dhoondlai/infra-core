
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.63.1"
    }
  }
}


provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "Owner"     = "dhoondlai"
      "ManagedBy" = "infra-core"
    }
  }
}
