# ==============================================================================
# Amazon ECR Repository: Data Source for Manually Created ajp/babylon Registry
# ==============================================================================

data "aws_ecr_repository" "babylon" {
  name = var.repository_name
}
