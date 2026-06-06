# Infisical Integration - Open Questions

Before proceeding with the implementation of Infisical as the secrets manager for the Babylon deployment stack, we need to clarify the following technical decisions:

1. **Self-Hosted vs. Cloud Infisical**
   Should we run a self-hosted Infisical instance locally inside the Docker Compose stack (which requires spinning up the Infisical backend/frontend image, Redis, and configuring Postgres/Mongo as its DB), or should we connect to an external hosted Infisical instance (e.g., Infisical Cloud)?
   * *Recommendation*: For local development and to keep the stack lightweight, we recommend utilizing Infisical Cloud or a pre-existing self-hosted instance, specifying the `INFISICAL_API_URL` and client credentials. If an isolated local instance is required, we can add a self-hosted Infisical configuration to the compose stack, but it will increase memory/resource usage due to Redis and database dependencies.

**Answwer**
We wnat to self-manage our own Infisical instance for `Babylon`.
Create a phased approach. We want to eventually reach a phase of being able to add the frontend image for a cloud deploy.

2. **Secrets Retrieval Mechanism**
   How should the `babylon-app` (and other containers) retrieve secrets from Infisical?
   * *Option A (Code-level integration)*: Implement an `InfisicalSecretsManager` using the official `infisical-python-sdk` in the `babylon` server codebase (similar to how `BaoSecretsManager` currently works).
   * *Option B (CLI injection)*: Install the Infisical CLI inside the `babylon-app` Docker image and start the container using `infisical run -- gunicorn ...`. This injects secrets directly as environment variables, requiring zero changes to the python application code.
   * *Recommendation*: Option B (CLI injection) is faster, cleaner, and adheres to 12-factor app principles by treating secrets as environment variables, but Option A provides tighter integration if the app needs to dynamically read/write secrets at runtime.

**Answer**
Option B, but we do want to keep flexibility in mind in case requirements change.


3. **Authentication Method**
   Which machine-to-machine authentication method should be used for the containerized services?
   * *Option A*: **Machine Identities** (Client ID and Client Secret, which is the current recommended approach by Infisical).
   * *Option B*: **Service Tokens** (now deprecated by Infisical but simpler to configure via a single environment variable).

**Answer**
Option A.

4. **Local Seeding & Initialization**
   How should we seed the initial secrets (`DB_HOST`, `DB_PORT`, etc.) for local development?
   * In OpenBao, we used a custom shell script (`setup-local-secrets.sh`) with `curl` to write secrets to the local server.
   * For Infisical, should we write a similar script using the Infisical API (e.g., `/v3/secrets/raw`) or assume secrets are pre-populated by the user in their Infisical project/environment?

**Answer**

For consistency purposes, we need a similar script for local testing.

5. **Infisical Project, Environment, and Secret Path Mapping**
   What organization structure should we use in Infisical?
   * E.g., Project: `babylon`, Environment: `dev`, Path: `/` or `/database`.

**Answer**
- organization: `babylon`
- Environment `dev`
- Whichever is the most secure. Ensure we have this decision well-documented in `docs`.
   
   
