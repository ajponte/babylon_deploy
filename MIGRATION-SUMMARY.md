# Infisical Secrets Manager Migration Summary

This document summarizes the changes made to migrate the Babylon application stack from HashiCorp OpenBao/Vault to **Infisical Secrets Manager**.

---

## 1. Local Deployment Infrastructure (`babylon_deploy`)

The local Docker Compose stack has been updated to replace OpenBao with a self-hosted Infisical instance and Redis caching layer.

### Core Changes
*   **Removed OpenBao**: Cleaned up the `openbao` container, volume (`openbao_data`), and associated environment configurations from [docker-compose.yml](file:///Users/aponte/personal_workspace/babylon-2.0/babylon_deploy/local/docker-compose.yml).
*   **Added Redis & Infisical**: Added `infisical-redis` (`redis:7-alpine`) and the unified `infisical` (`infisical/infisical:latest`) service to the stack, linking it to the existing `postgres` database container.
*   **CLI Container Injection**: Updated [Dockerfile](file:///Users/aponte/personal_workspace/babylon-2.0/babylon_deploy/local/Dockerfile) to download and install the official `infisical` CLI and updated the runtime command (`CMD`) to run via:
    ```bash
    infisical run --env=dev --path=/ -- gunicorn --bind 0.0.0.0:8000 --workers 4 production:application
    ```
*   **Machine Identity Injection**: Configured the `babylon-app` container in [docker-compose.yml](file:///Users/aponte/personal_workspace/babylon-2.0/babylon_deploy/local/docker-compose.yml) to accept Infisical authentication parameters (`INFISICAL_API_URL`, `INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, and `INFISICAL_PROJECT_ID`). Cleaned up unused OpenBao variables from the `mongodb` service.

### Automation & Seeding
*   **Infisical Setup Script**: Created [setup-local-infisical.sh](file:///Users/aponte/personal_workspace/babylon-2.0/babylon_deploy/local/tools/setup-local-infisical.sh) to:
    1.  Automatically generate secure `INFISICAL_ENCRYPTION_KEY` and `INFISICAL_AUTH_SECRET` if not already present.
    2.  Wait for the Infisical health endpoint (`/api/status`) to be ready.
    3.  Bootstrap the admin user, organization (`babylon`), and project (`babylon`).
    4.  Provision the `babylon-app` Machine Identity and link it to the project with the `admin` role.
    5.  Fetch Universal Auth Client ID and generate a Client Secret.
    6.  Seed the required database secrets (`DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`) under the `dev` environment at the `/` path.
    7.  Save credentials to `local/.env` and reapply `docker compose up` to start the app with runtime secret injection.
*   **Updated Entrypoint**: Updated [start_stack.sh](file:///Users/aponte/personal_workspace/babylon-2.0/babylon_deploy/start_stack.sh) to invoke `setup-local-infisical.sh` instead of the old `setup-local-secrets.sh`.

---

## 2. Python Application Config Loader (`babylon`)

The python application server has been updated to handle secrets dynamically via CLI injection (environment variables) or direct SDK programmatic lookup.

### Dependency Updates
*   **SDK Added**: Updated [pyproject.toml](file:///Users/aponte/personal_workspace/babylon-2.0/babylon/pyproject.toml) to declare `infisicalsdk = "^2.2.0"`.

### Config Updates
*   **Config Definitions**: Updated [config.py](file:///Users/aponte/personal_workspace/babylon-2.0/babylon/server/config/config.py) to demote `BAO_ADDR` and `OPENBAO_SECRETS_PATH` to optional loaders to prevent boot crashes and added loaders for `INFISICAL_API_URL`, `INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`, `INFISICAL_PROJECT_ID`, and `INFISICAL_ENV`.
*   **Programmatic Client**: Created [infisical.py](file:///Users/aponte/personal_workspace/babylon-2.0/babylon/server/config/infisical.py) implementing `InfisicalSecretsManager` subclassing `AbstractSecretsManager`. The client authenticates using Universal Auth and fetches secrets programmatically using the official `infisicalsdk` client.
*   **Three-Way Secret Routing**: Updated [confload.py](file:///Users/aponte/personal_workspace/babylon-2.0/babylon/server/config/confload.py) `get_secret_value` to support:
    1.  **CLI Injection (Default)**: Direct lookups in `os.environ`. If variables (like `DB_HOST`) are already present in the environment (injected via `infisical run`), they are used immediately, bypassing SDK overhead.
    2.  **Programmatic Infisical SDK**: Resolving secrets using `InfisicalSecretsManager` if `INFISICAL_CLIENT_ID` is present.
    3.  **Backward Compatibility (Fallback)**: Falling back to `BaoSecretsManager` if no Infisical variables are set.

### Test Coverage
*   **Unit Tests**: Created [test_infisical.py](file:///Users/aponte/personal_workspace/babylon-2.0/babylon/tests/test_infisical.py) to verify client singleton instantiation, universal auth setup, correct parameter passing to the Infisical API, and three-way routing behaviors.
