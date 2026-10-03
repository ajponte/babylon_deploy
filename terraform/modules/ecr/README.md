# Terraform IaC for Shared Amazon ECR Repository
 
This module manages the configuration and outputs for the shared Amazon ECR container registry (`ajp/babylon`) and GitHub Actions OIDC integration:
- **ECR Repository**: Discovers the pre-existing container registry where multi-service Babylon images are published via `data "aws_ecr_repository"`.
- **GitHub Actions OIDC**: Consumes the externally managed `github-actions-babylon-deploy` role for OIDC-authenticated push and deployment operations.

> [!NOTE]
> **Out-of-Band Repository Provisioning**: This module strictly consumes pre-existing ECR repositories and never creates them. Repository creation and lifecycle policy attachment must be performed externally using [`tools/setup-ecr.sh`](../../../tools/setup-ecr.sh).

