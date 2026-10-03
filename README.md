# babylon_deploy

Babylon stack deployment repository. Manages local Docker stack and deployments to remote clouds and resources.

## Local Development

### Prerequisites

Before starting the stack, you must set the following environment variable:

- `BABYLON_API_GITHUB_PAT_TOKEN`: A GitHub Personal Access Token (PAT) with read access to the `ajponte/babylon` and `ajponte/babylon_api_spec` repositories. This is used during the Docker build process to pull application artifacts and API specifications.

### Quick Start

```bash
# Set your GitHub PAT token
export BABYLON_API_GITHUB_PAT_TOKEN=your_token_here

# Build and start the Docker stack
# This will also automatically initialize required secrets in OpenBao
./start_stack.sh

# Verify babylon-app health
./health-babylon-app.sh

# Stop the stack
./stop_stack.sh
```

### Services

The Babylon stack includes:

- **OpenBao** - Secrets management (port 8200)
- **PostgreSQL** - Primary database (port 5432)
- **MongoDB** - Data lake (port 27017)
- **ChromaDB** - Vector store (port 8003)
- **Qdrant** - Vector database (port 6333)
- **ZenML** - ML pipeline orchestration (port 8081)
- **Babylon App** - Main application (port 5001)

All services run on the `babylon` Docker network.

### Scripts

| Script | Description |
|--------|-------------|
| `start_stack.sh` | Builds and starts the Docker stack and initializes OpenBao secrets. |
| `stop_stack.sh` | Stops and removes the Docker stack. |
| `health-babylon-app.sh` | Pings the `babylon-app` health route to verify it is running correctly. |
| `local/tools/setup-local-secrets.sh` | Manually initializes or refreshes OpenBao secrets (run automatically by `start_stack.sh`). |
| `local/tools/scan-secrets.sh` | Scans git working tree and diff for hardcoded credentials, keys, or sensitive files. |
| `local/test_bao.sh` | Tests OpenBao secrets retrieval and connectivity. |

### Mongo DB Connection
The connection settings to the local mongo db docker service is defined in `local/compass-connections.json`.

---

## Cloud Infrastructure (Terraform)

Cloud infrastructure is provisioned declaratively via Terraform under [`terraform/`](./terraform/).

### Quick Commands

```bash
# Initialize Terraform and download providers
terraform -chdir=terraform init

# Validate configuration syntax and schema
terraform -chdir=terraform validate

# Generate a speculative execution plan using example variables
terraform -chdir=terraform plan -var-file=terraform.tfvars.example
```

See [`terraform/README.md`](./terraform/README.md) for more details on modules and variables.

---

## Documentation Harness

This repository maintains an integrated documentation harness rooted at [`docs/`](./docs/):

- **[`docs/README.md`](./docs/README.md)**: Master index and map of the documentation harness.
- **[`AGENTS.md`](./AGENTS.md)**: Source of truth system prompt and operational guide for AI agents (Gemini, Claude, OpenAI, Antigravity) adhering to the Agentic AI Foundation (AAIF) open standard.
- **[`docs/specs/`](./docs/specs/)**: Repository of Architectural Decision Records (ADRs) and formal technical specifications for cloud and local infrastructure (see [`docs/specs/README.md`](./docs/specs/README.md)).
- **[`BABYLON-APP-FIXES.md`](./BABYLON-APP-FIXES.md)**: Historical notes and debugging logs for local `babylon-app` setup.

---

## Agent Verification & Safety Loop

Autonomous agents and contributors must run the mandatory verification loop before proposing changes or submitting pull requests:

1. **Secret & Key Scanning**: Run `./local/tools/scan-secrets.sh` to confirm no AWS keys, private keys, PATs, or passwords are hardcoded in modified, staged, or untracked files.
2. **Terraform Syntax Validation (Mandatory Offline)**: Run `terraform -chdir=terraform validate` to ensure configuration syntax and provider schemas are valid without requiring cloud credentials.
3. **Speculative Plan Generation (Online)**: Run `terraform -chdir=terraform plan -var-file=terraform.tfvars.example` to confirm speculative plan generation succeeds when authenticated with AWS.
4. **Human Review Gate**: **Never commit code (`git commit`) directly**. Leave changes uncommitted for user review.

