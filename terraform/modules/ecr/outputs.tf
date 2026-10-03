# ==============================================================================
# Outputs for Shared Amazon ECR Repository Module (Data Sources)
# ==============================================================================

output "repository_name" {
  description = "Name of the Amazon ECR repository"
  value       = data.aws_ecr_repository.babylon.name
}

output "repository_url" {
  description = "The URL of the Amazon ECR repository"
  value       = data.aws_ecr_repository.babylon.repository_url
}

output "repository_arn" {
  description = "The ARN of the Amazon ECR repository"
  value       = data.aws_ecr_repository.babylon.arn
}

output "github_actions_role_arn" {
  description = "The IAM Role ARN for GitHub Actions OIDC authentication"
  value       = data.aws_iam_role.github_actions_deploy.arn
}
