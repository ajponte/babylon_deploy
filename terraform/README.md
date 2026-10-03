# Babylon Infrastructure as Code (Terraform)

This directory contains the Terraform Infrastructure as Code (IaC) configurations for provisioning and managing Babylon personal finance cloud resources on **Amazon Web Services (AWS)** and **MongoDB Atlas**.

---

## Architecture & Directory Layout

```
terraform/
├── main.tf                    # Root Terraform configuration & AWS provider setup
├── variables.tf               # Input variable declarations & type definitions
├── outputs.tf                 # Foundation outputs & module exports
├── terraform.tfvars.example   # Example variable definitions for speculative planning
├── .terraform.lock.hcl        # Pinned provider versions and dependency checksums
└── modules/
    ├── ecr/                   # Shared Amazon ECR repository and GitHub Actions OIDC integration
    ├── datalake/              # S3 landing storage & AWS Secrets Manager datalake credentials
    └── data-loader/           # Data Loader serverless compute (AWS Lambda & S3 trigger)
```

### State Management
The root configuration uses a **local backend** storing state in `terraform.tfstate` within this directory. Local state files (`*.tfstate`, `*.tfstate.*`) are strictly gitignored to prevent leaking infrastructure state or generated secrets.

---

## Providers & Dependencies

| Provider | Source | Version Constraint | Purpose |
| :--- | :--- | :--- | :--- |
| `aws` | `hashicorp/aws` | `~> 5.0` | AWS VPC integration, IAM policies, and cloud resources |
| `random` | `hashicorp/random` | `~> 3.5` | Unique identifier generation for resource naming |
| `mongodbatlas` | `mongodb/mongodbatlas` | Phase 2 | Planned for MongoDB Atlas M0 cluster provisioning |

---

## Variables & Configuration

Configuration variables are defined in [`variables.tf`](./variables.tf). To configure your local deployment:

1. Copy [`terraform.tfvars.example`](./terraform.tfvars.example) to `terraform.tfvars` (which is gitignored):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Populate the required values:

| Variable | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `aws_region` | `string` | `"us-west-2"` | Target AWS region for deployment |
| `vpc_id` | `string` | `"vpc-0c2611c0821789bca"` | Attached AWS VPC identifier |
| `mongodbatlas_public_key` | `string` | *Required* | Atlas Programmatic API Public Key |
| `mongodbatlas_private_key`| `string` | *Required* (sensitive) | Atlas Programmatic API Private Key |
| `mongodbatlas_org_id`     | `string` | *Required* | MongoDB Atlas Organization ID |
| `atlas_region`            | `string` | `"US_WEST_2"` | MongoDB Atlas cloud provider region |

> [!CAUTION]
> **Never commit `terraform.tfvars` containing real credentials.** Only `terraform.tfvars.example` is committed to version control.

---

## Execution & Verification Commands

### 1. Initialize Working Directory
Downloads provider plugins and prepares local backend:
```bash
terraform -chdir=terraform init
```

### 2. Validate Configuration (Offline)
Verifies syntax, variable definitions, and provider schemas without needing cloud credentials:
```bash
terraform -chdir=terraform validate
```

### 3. Generate Speculative Plan (Online)
Evaluates infrastructure state and generates an execution preview. Requires authenticated AWS credentials (for caller identity verification):
```bash
terraform -chdir=terraform plan -var-file=terraform.tfvars.example
```

---

## Roadmap & Modular Phases

Cloud infrastructure aligns with the Architectural Decision Records in [`../docs/specs/`](../docs/specs/):

- **Phase 1 (Current)**: Foundation configuration (AWS Provider, VPC configuration, caller identity, and output scaffolding).
- **Phase 2 (Planned)**: Datalake & persistence module (`modules/datalake-atlas`) deploying MongoDB Atlas M0 Free Tier, AWS Secrets Manager credentials, and S3 landing buckets.
- **Phase 3 (Planned)**: Serverless compute module (`modules/data-loader`) deploying ARM64 Graviton AWS Lambda container triggered by S3 file events (see [`../docs/specs/data-loader-serverless-pipeline.md`](../docs/specs/data-loader-serverless-pipeline.md)).
