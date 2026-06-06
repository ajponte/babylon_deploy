# Updated Plan: Transitioning to Infisical Secrets Manager

Based on the decisions made:
1. **Self-Managed Instance**: We will spin up a self-managed Infisical instance in the local Docker Compose stack (`local/docker-compose.yml`), preparing a phased transition suitable for future cloud deployments.
2. **Secrets Retrieval**: We will use **Option B (CLI injection)** via `infisical run` for the runtime container, but implement a Python abstract layer placeholder to maintain code-level flexibility.
3. **Authentication**: We will use **Universal Auth (Machine Identities)** with Client ID and Client Secret.
4. **Local Seeding**: We will automate the bootstrap and seeding process using a new `setup-local-infisical.sh` script for consistency with the previous OpenBao flow.
5. **Organization & Structure**: 
   * **Organization**: `babylon`
   * **Environment**: `dev`
   * **Path**: `/` (root path, with folder nesting if needed for security).
   * **Documentation**: Decisions will be fully captured in `docs/Infisical-Secrets-Mapping.md`.

---

## Phase 1: Local Stack Configuration (`babylon_deploy`)

We will update the local Docker Compose infrastructure to support the self-hosted Infisical service.

### 1.1 Remove OpenBao and Add Redis & Infisical Services
In `local/docker-compose.yml`, replace the `openbao` service with:
* **Redis**: Used by Infisical for caching and queues.
* **Infisical**: The unified self-hosted image (`infisical/infisical:latest`), serving both the UI and the API.

We will configure Infisical to store its data in the existing `postgres` database container to minimize resource overhead, using a database named `babylon` (sharing it with the app) or configuring the postgres container to initialize a separate `infisical` database.

#### Draft Compose Addition:
```yaml
  infisical-redis:
    image: redis:7-alpine
    container_name: infisical-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - babylon

  infisical:
    image: infisical/infisical:latest
    container_name: infisical
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
      infisical-redis:
        condition: service_started
    ports:
      - "8201:8080" # Map UI/API to 8201 on the host
    environment:
      - NODE_ENV=production
      - DB_CONNECTION_URI=postgresql://user:password@postgres:5432/babylon
      - REDIS_URL=redis://infisical-redis:6379
      - ENCRYPTION_KEY=${INFISICAL_ENCRYPTION_KEY} # Generated dynamically or loaded from .env
      - AUTH_SECRET=${INFISICAL_AUTH_SECRET}       # Generated dynamically or loaded from .env
      - SITE_URL=http://localhost:8201
    networks:
      - babylon
```

---

## Phase 2: Application Container Integration (`babylon_deploy`)

We will adapt `local/Dockerfile` to install the Infisical CLI and wrap the runtime process.

### 2.1 Update `local/Dockerfile`
Modify the Dockerfile to fetch and install the CLI:
```dockerfile
# Add Infisical repository and install CLI
RUN apt-get update && apt-get install -y curl && \
    curl -1sLf 'https://artifacts-cli.infisical.com/setup.deb.sh' | bash && \
    apt-get install -y infisical && \
    rm -rf /var/lib/apt/lists/*
```

### 2.2 Update Container CMD and Environment
Change Gunicorn's execution to go through `infisical run`:
```dockerfile
CMD ["infisical", "run", "--env=dev", "--path=/", "--", "gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "production:application"]
```

In `local/docker-compose.yml`, change the `babylon-app` environment to pass Infisical Machine Identity credentials:
```yaml
    environment:
      - INFISICAL_API_URL=http://infisical:8080
      - INFISICAL_CLIENT_ID=${INFISICAL_CLIENT_ID}
      - INFISICAL_CLIENT_SECRET=${INFISICAL_CLIENT_SECRET}
      - INFISICAL_PROJECT_ID=${INFISICAL_PROJECT_ID}
      # The app itself no longer needs direct DB credentials in its compose definition 
      # since they are injected at boot by Infisical CLI.
```

---

## Phase 3: Seeding & Bootstrap Script (`babylon_deploy`)

We will create `local/tools/setup-local-infisical.sh` to initialize the fresh Infisical instance and seed the secrets.

### 3.1 Seeding Script Flow
1. **Wait for Infisical**: Loop until `http://localhost:8201/api/v1/health` is ready.
2. **Bootstrap Instance**: Run `infisical bootstrap` (or use cURL on `/api/v1/bootstrap` endpoint) to create the initial admin user, organization `babylon`, and retrieve the initial access token.
3. **Create Project**: Use the admin token to create the `babylon` project.
4. **Create Machine Identity (Universal Auth)**: Create a Machine Identity for the application, generating a `Client ID` and `Client Secret` with access to the `dev` environment.
5. **Seed Secrets**: Upload the required development secrets (`DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`) under the `dev` environment at the root path (`/`).
6. **Output Credentials**: Save the generated `Client ID`, `Client Secret`, and `Project ID` to `local/.env` so the Docker stack can load them.

---

## Phase 4: Codebase Code-Level Flexibility (`babylon`)

To keep runtime flexibility in case we decide to pull secrets programmatically later, we will update the config loader structure in the Python server.

### 4.1 Define an Abstract Secrets Manager Driver
In `babylon/server/config/`, we can keep `BaoSecretsManager` for backwards-compatibility or migration, and introduce `InfisicalSecretsManager` in a new file `babylon/server/config/infisical.py` using `infisical-python-sdk`:

```python
from server.config.hashicorp import AbstractSecretsManager
from infisical_sdk import InfisicalSDK

class InfisicalSecretsManager(AbstractSecretsManager):
    """Infisical SDK implementation of AbstractSecretsManager."""
    
    _instance = None
    
    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super(InfisicalSecretsManager, cls).__new__(cls)
            cls._instance.client = InfisicalSDK(
                api_url=os.environ.get("INFISICAL_API_URL", "https://app.infisical.com")
            )
            # Authenticate via Universal Auth
            cls._instance.client.auth.universal_login(
                client_id=os.environ.get("INFISICAL_CLIENT_ID"),
                client_secret=os.environ.get("INFISICAL_CLIENT_SECRET")
            )
        return cls._instance

    def get_secret(self, path: str, key: str) -> dict:
        secret = self.client.secrets.get_secret(
            secret_name=key,
            project_id=os.environ.get("INFISICAL_PROJECT_ID"),
            environment=os.environ.get("INFISICAL_ENV", "dev"),
            path=path
        )
        return {"key": key, "val": secret.secret_value}
```

By maintaining this class, we can easily toggle the secrets loading mechanism in `confload.py` between reading from injected environment variables (CLI method) and calling the SDK directly.

---

## Phase 5: Verification & Testing

1. Run `./start_stack.sh` which executes the docker-compose services and runs `setup-local-infisical.sh`.
2. Check that the Infisical dashboard is reachable at `http://localhost:8201`.
3. Verify `babylon-app` successfully boots up and accesses the database.
4. Run the healthcheck script `./health-babylon-app.sh` to confirm 200 OK.
