terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    bucket         = "babylon-terraform-state-615471835001"
    key            = "babylon_deploy/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "babylon-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for current caller identity
data "aws_caller_identity" "current" {}

# ==============================================================================
# Shared Infrastructure: Amazon ECR Repository (ajp/babylon)
# ==============================================================================
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "ajp/babylon"
}

# ==============================================================================
# Shared Infrastructure: Datalake S3 Landing Bucket & Secrets Manager
# ==============================================================================
module "datalake" {
  source     = "./modules/datalake"
  aws_region = var.aws_region
}

# ==============================================================================
# Service Infrastructure: Data Loader Serverless Compute (AWS Lambda)
# ==============================================================================
module "data_loader" {
  source                = "./modules/data-loader"
  aws_region            = var.aws_region
  s3_landing_bucket_id  = module.datalake.s3_landing_bucket_id
  s3_landing_bucket_arn = module.datalake.s3_landing_bucket_arn
  datalake_secret_arn   = module.datalake.datalake_secret_arn
  ecr_repository_url    = module.ecr.repository_url
}
