terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=5.20.0"
    }
  }
}

provider "aws" {
    region = var.region
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}
