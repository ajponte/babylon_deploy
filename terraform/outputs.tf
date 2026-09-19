# ==============================================================================
# Foundation Outputs
# ==============================================================================

output "aws_region" {
  description = "AWS region for deployed infrastructure"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS Account ID where infrastructure is deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "environment" {
  description = "Deployment environment name"
  value       = var.environment
}

output "vpc_id" {
  description = "VPC ID where Babylon infrastructure and networking are attached"
  value       = var.vpc_id
}

# ==============================================================================
# Expected Exports: Datalake & Persistence (Phase 2 - modules/datalake-atlas)
# To be activated when modules/datalake-atlas is provisioned
# ==============================================================================

# output "s3_landing_bucket_name" {
#   description = "Name of the S3 landing bucket for raw transaction CSVs"
#   value       = module.datalake.s3_landing_bucket_name
# }

# output "s3_landing_bucket_arn" {
#   description = "ARN of the S3 landing bucket"
#   value       = module.datalake.s3_landing_bucket_arn
# }

# output "datalake_secret_arn" {
#   description = "ARN of the AWS Secrets Manager secret containing MongoDB Atlas credentials"
#   value       = module.datalake.db_secret_arn
# }

# output "mongodbatlas_cluster_name" {
#   description = "Name of the MongoDB Atlas M0 cluster"
#   value       = module.datalake.mongodbatlas_cluster_name
# }

# ==============================================================================
# Expected Exports: Data Loader Compute (Phase 3 - modules/data-loader)
# To be activated when modules/data-loader (Lambda & ECR) is provisioned
# ==============================================================================

# output "ecr_repository_url" {
#   description = "URL of the Amazon ECR repository for the Data Loader container"
#   value       = module.data_loader.ecr_repository_url
# }

# output "lambda_function_arn" {
#   description = "ARN of the Data Loader AWS Lambda function"
#   value       = module.data_loader.lambda_function_arn
# }

# output "lambda_function_name" {
#   description = "Name of the Data Loader AWS Lambda function"
#   value       = module.data_loader.lambda_function_name
# }

# output "lambda_execution_role_arn" {
#   description = "ARN of the IAM role assumed by the Data Loader Lambda function"
#   value       = module.data_loader.task_role_arn
# }
