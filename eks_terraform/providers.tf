provider "aws" {
  default_tags {
    tags = local.tags
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.10.0"
    }


  }

  required_version = ">= 1.4.2"
}
