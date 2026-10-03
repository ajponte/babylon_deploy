# Terraform IaC for Shared Amazon ECR Repository
 
This module manages the configuration and outputs for the shared Amazon ECR container registry (`ajp/babylon`) and GitHub Actions OIDC integration:
- **ECR Repository**: Discovers the pre-existing container registry where multi-service Babylon images are published.
- **GitHub Actions OIDC**: Consumes the externally managed `github-actions-babylon-deploy` role for OIDC-authenticated push and deployment operations.
