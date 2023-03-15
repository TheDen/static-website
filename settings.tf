terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.58.0"
    }
  }
  required_version = ">= 0.15"
}

provider "aws" {
  region = "ap-southeast-2"
}
