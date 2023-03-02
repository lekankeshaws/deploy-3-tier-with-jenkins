

#########################################################
# TERRAFORM BLOCK
#########################################################

terraform {
  required_version = ">=1.1.0"

  backend "s3" {
    bucket = "backend-0301-lekan-kesh-buck"
    key    = "path/env"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#########################################################
# PROVIDER BLOCK
#########################################################

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      env       = var.env
      component = var.component
    }

  }
}

#########################################################
# LOCAL BLOCK
#########################################################

locals {
  vpc_id = module.vpc.vpc_id
  azs    = slice(data.aws_availability_zones.available.names, 0, 2)
}

#########################################################
# DATA SOURCE BLOCK
#########################################################
data "aws_availability_zones" "available" {
  state = "available"

}

#########################################################
# VPC RESOURCE
#########################################################

module "vpc" {
  source = "git::https://github.com/lekankeshaws/vpc-module.git"

  component            = var.component
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.azs
  public_subnet_cidr   = var.public_subnet_cidr
  backend_subnet_cidr  = var.backend_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr

}
