terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
    backend "s3" {
    bucket = "deepakstest2"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}