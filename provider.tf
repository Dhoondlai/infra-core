
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.63"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.29.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
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

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email   = "parhlai.dev@gmail.com"
}
