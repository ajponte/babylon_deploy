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



output "vpc_id" {
  description = "VPC ID where Babylon infrastructure and networking are attached"
  value       = var.vpc_id
}

# ==============================================================================
# Shared Container Infrastructure Outputs (Amazon ECR - ajp/babylon)
# ==============================================================================

output "ecr_repository_name" {
  description = "Name of the shared Amazon ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "The URL of the Amazon ECR repository (ajp/babylon)"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the Amazon ECR repository (ajp/babylon)"
  value       = module.ecr.repository_arn
}

output "github_actions_ecr_role_arn" {
  description = "The IAM Role ARN for GitHub Actions OIDC authentication across Babylon repositories"
  value       = module.ecr.github_actions_role_arn
}

# ==============================================================================
# Datalake Storage & Credentials Outputs (modules/datalake)
# ==============================================================================

output "s3_landing_bucket_name" {
  description = "Name of the S3 landing bucket for raw transaction CSVs"
  value       = module.datalake.s3_landing_bucket_name
}

output "s3_landing_bucket_arn" {
  description = "ARN of the S3 landing bucket"
  value       = module.datalake.s3_landing_bucket_arn
}

output "datalake_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing datalake credentials"
  value       = module.datalake.datalake_secret_arn
}

output "datalake_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing datalake credentials"
  value       = module.datalake.datalake_secret_name
}

# ==============================================================================
# Data Loader Compute Outputs (modules/data-loader)
# ==============================================================================

output "lambda_function_name" {
  description = "Name of the Data Loader AWS Lambda function"
  value       = module.data_loader.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Data Loader AWS Lambda function"
  value       = module.data_loader.lambda_function_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the IAM role assumed by the Data Loader Lambda function"
  value       = module.data_loader.lambda_role_arn
}
