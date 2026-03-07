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

### Documentation

For more detailed information on issues addressed during the setup of the `babylon-app` service, see [BABYLON-APP-FIXES.md](./BABYLON-APP-FIXES.md).

### Mongo DB Connection
The connection settings to the local mongo db docker service is defined in `local/compass-connections.json`
