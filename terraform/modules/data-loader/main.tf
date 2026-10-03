# ==============================================================================
# Data Loader Compute Module (AWS Lambda)
#
# NOTE: IAM roles and policies are managed strictly OUTSIDE of Terraform.
# ==============================================================================

# Data source for current caller identity
data "aws_caller_identity" "current" {}

# ==============================================================================
# Externally Managed IAM Execution Role
# ==============================================================================
data "aws_iam_role" "lambda_execution" {
  name = var.lambda_role_name
}

# ==============================================================================
# Amazon CloudWatch Log Group
# ==============================================================================
resource "aws_cloudwatch_log_group" "data_loader" {
  name              = "/aws/lambda/babylon-data-loader"
  retention_in_days = 14

  tags = var.tags
}

# ==============================================================================
# AWS Lambda Function (ARM64 Container Image)
# ==============================================================================
resource "aws_lambda_function" "data_loader" {
  function_name = "babylon-data-loader"
  description   = "Serverless financial transaction CSV ingestion engine for Babylon datalake"
  role          = data.aws_iam_role.lambda_execution.arn

  package_type  = "Image"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 300 # 5 minutes

  # Initial bootstrap image from shared ECR repository
  image_uri = "${var.ecr_repository_url}:data-loader-latest"

  environment {
    variables = {
      MONGO_SECRET_ID = var.datalake_secret_arn
      LAMBDA_TMP_DIR  = "/tmp"
      AWS_REGION      = var.aws_region
    }
  }

  tags = var.tags

  # CRITICAL: Prevent Terraform from rolling back or overwriting container releases
  # deployed independently by babylon_data_loader's CI/CD pipeline.
  lifecycle {
    ignore_changes = [
      image_uri,
    ]
  }

  depends_on = [
    aws_cloudwatch_log_group.data_loader,
  ]
}

# ==============================================================================
# S3 Invocation Permission for Lambda
# ==============================================================================
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_loader.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_landing_bucket_arn
}

# ==============================================================================
# S3 Event Notification Trigger
# ==============================================================================
resource "aws_s3_bucket_notification" "data_loader_trigger" {
  bucket = var.s3_landing_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "unprocessed/"
    filter_suffix       = ".csv"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_loader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "unprocessed/"
    filter_suffix       = ".CSV"
  }

  depends_on = [
    aws_lambda_permission.allow_s3,
  ]
}
