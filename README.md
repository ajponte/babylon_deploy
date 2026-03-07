# babylon_deploy

Babylon stack deployment repository. Manages local Docker stack and deployments to remote clouds and resources.

## Local Development

### Quick Start

```bash
# Build and start the Docker stack
./start_stack.sh

# Run tests
./test_stack.sh

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
| `start_stack.sh` | Builds and starts the Docker stack |
| `stop_stack.sh` | Stops and removes the Docker stack |
| `test_stack.sh` | Runs tests on the running stack |


### Mongo DB Connection
The connection settings to the local mongo db docker service is defined in `local/compass-connections.json`
