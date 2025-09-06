terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "tf-state-194722428485-ca-central-1" # your bucket name
    key            = "capstone/region-a/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

provider "aws" {
  region = var.region # usually set in terraform.tfvars → region = "ca-central-1"
}
