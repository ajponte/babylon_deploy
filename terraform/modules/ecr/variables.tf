# ==============================================================================
# Variables for Shared Amazon ECR Repository Module
# ==============================================================================

variable "repository_name" {
  description = "Name of the Amazon ECR repository"
  type        = string
  default     = "ajp/babylon"
}



variable "github_actions_role_name" {
  description = "Name of the externally managed IAM role assumed by GitHub Actions for deployment"
  type        = string
  default     = "github-actions-babylon-deploy"
}

variable "allowed_github_repositories" {
  description = "List of GitHub repositories allowed to assume the deploy role via OIDC"
  type        = list(string)
  default     = ["repo:ajponte/babylon*:*"]
}
