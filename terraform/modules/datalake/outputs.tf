# ==============================================================================
# Outputs for Datalake Module
# ==============================================================================

output "s3_landing_bucket_id" {
  description = "The ID/Name of the S3 landing bucket"
  value       = aws_s3_bucket.landing.id
}

output "s3_landing_bucket_name" {
  description = "The name of the S3 landing bucket for raw transaction CSVs"
  value       = aws_s3_bucket.landing.bucket
}

output "s3_landing_bucket_arn" {
  description = "The ARN of the S3 landing bucket"
  value       = aws_s3_bucket.landing.arn
}

output "datalake_secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret storing datalake credentials"
  value       = aws_secretsmanager_secret.datalake_credentials.arn
}

output "datalake_secret_name" {
  description = "The name of the AWS Secrets Manager secret storing datalake credentials"
  value       = aws_secretsmanager_secret.datalake_credentials.name
}
