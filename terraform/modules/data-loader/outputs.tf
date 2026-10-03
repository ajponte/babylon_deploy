# ==============================================================================
# Outputs for Data Loader Compute Module (Lambda)
# ==============================================================================

output "lambda_function_name" {
  description = "The name of the Data Loader AWS Lambda function"
  value       = aws_lambda_function.data_loader.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Data Loader AWS Lambda function"
  value       = aws_lambda_function.data_loader.arn
}

output "lambda_role_arn" {
  description = "ARN of the externally managed IAM role for the Data Loader Lambda function"
  value       = data.aws_iam_role.lambda_execution.arn
}

output "lambda_role_name" {
  description = "Name of the externally managed IAM role for the Data Loader Lambda function"
  value       = data.aws_iam_role.lambda_execution.name
}
