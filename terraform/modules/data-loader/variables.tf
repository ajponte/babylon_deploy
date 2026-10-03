variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "lambda_role_name" {
  description = "Name of the externally managed IAM execution role for Data Loader Lambda"
  type        = string
  default     = "babylon-data-loader-lambda-role"
}

variable "s3_landing_bucket_id" {
  description = "The ID of the S3 landing bucket for attaching event notifications"
  type        = string
}

variable "s3_landing_bucket_arn" {
  description = "The ARN of the S3 landing bucket for Lambda invocation permissions"
  type        = string
}

variable "datalake_secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret storing datalake credentials"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the Amazon ECR repository hosting the Lambda container image"
  type        = string
}

variable "tags" {
  description = "Tags to attach to data-loader compute resources"
  type        = map(string)
  default = {
    Project   = "babylon"
    Component = "data-loader"
    ManagedBy = "terraform"
  }
}