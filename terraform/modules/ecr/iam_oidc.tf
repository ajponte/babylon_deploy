# ==============================================================================
# GitHub Actions OpenID Connect (OIDC) Identity Provider & Deploy Role
#
# NOTE: IAM roles and policies are managed strictly OUTSIDE of Terraform.
# ==============================================================================

# Data source for pre-existing OIDC provider
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# ==============================================================================
# Externally Managed GitHub Actions OIDC Role
# ==============================================================================
data "aws_iam_role" "github_actions_deploy" {
  name = var.github_actions_role_name
}
