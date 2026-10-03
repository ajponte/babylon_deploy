# Babylon App Fixes

## Issues and Required Changes
- [x] Update `Dockerfile` to pull `babylon.zip` from GitHub releases using `BABYLON_API_GITHUB_PAT_TOKEN`.
- [x] Update `docker-compose.yml` to pass `BABYLON_API_GITHUB_PAT_TOKEN` as a build argument.
- [x] Ensure `babylon-app` wait-for-it or healthchecks are properly configured for all dependencies. (Added OpenBao healthcheck).
- [x] Verify if the zip unzips into the root or a subfolder. (It unzips into a tarball which must be extracted).
- [x] Add `curl` to the `babylon-app` container for health checking if needed. (Added via `apt-get` in Dockerfile).
- [x] **ISSUE:** `github_artifacts.py` was missing from the deployment context.
    - **Fix:** Copied `github_artifacts.py` from `local/tools/` into the container.
- [x] **ISSUE:** `babylon-api-spec.yml` is missing from the artifact.
    - **Fix:** Used `github_artifacts.py` to download the spec from `ajponte/babylon_api_spec` during Docker build.
- [x] **ISSUE:** `production.py` is missing from the artifact.
    - **Fix:** Copied `babylon_app-LOCAL.py` from local context to `production.py` in the container.
- [x] **ISSUE:** Hardcoded secrets path `"test"` in `server/config/config.py`.
    - **Impact:** The app fails to boot if `secret/data/test` does not exist in OpenBao.
    - **Workaround:** Created `local/tools/setup-local-secrets.sh` to initialize OpenBao.
- [x] **ISSUE:** Application environment variables names mismatched between `docker-compose.yml` and `server/config/config.py`.
    - **Fix:** Updated `docker-compose.yml` with the correct variable names (e.g., removed `BABYLON_API_` prefix where required).
- [x] **ISSUE:** OpenBao authentication required `VAULT_TOKEN` instead of `BAO_TOKEN` in the specific application client.
    - **Fix:** Added `VAULT_TOKEN` to `babylon-app` environment.
- [x] **ISSUE:** `create_app()` returns a Connexion `FlaskApp` wrapper, but Gunicorn expects the underlying Flask `app`.
    - **Fix:** Updated `production.py` (LOCAL) to use `application = create_app().app`.

## Verification
- `health-babylon-app.sh` returns `OK` (200).
- All services in the stack are running.
