# Infisical Secrets Mapping and Organization

This document details the organizational design and security choices for mapping secrets within Infisical for the `Babylon` project.

---

## 1. Hierarchy & Structure

To ensure maximum isolation, ease of access control, and clean configurations, we structure secrets hierarchically within Infisical.

### 1.1 Organization & Projects
* **Organization**: `babylon`
* **Project**: `babylon`
  * Represents the entire backend application, including its dependent microservices (Flask application, ZenML pipelines, MongoDB data lake, etc.).

### 1.2 Environments
We define the following standard environments matching our deployment lifecycle:
* `dev`: Local containerized stack and sandbox testing.
* `staging`: Pre-production testing environment.
* `prod`: Live production environments.

---

## 2. Secrets Path Mapping (Secure Design)

Rather than keeping all secrets at the root path (`/`), we group them logically by service or access scope. This restricts permissions using fine-grained Machine Identity roles.

| Secret Path | Key / Variable Name | Description | Used By |
| :--- | :--- | :--- | :--- |
| `/database` | `DB_HOST` | Database host hostname | `babylon-app` |
| | `DB_PORT` | Database host port | `babylon-app` |
| | `DB_USERNAME` | Database connection username | `babylon-app`, `postgres` |
| | `DB_PASSWORD` | Database connection password | `babylon-app`, `postgres` |
| `/database` | `MONGO_URI` | Connection URI for MongoDB | `babylon-app`, `mongodb` |
| | `MONGO_INITDB_ROOT_USERNAME` | Admin user for MongoDB | `mongodb` |
| | `MONGO_INITDB_ROOT_PASSWORD` | Admin password for MongoDB | `mongodb` |
| `/integrations` | `BABYLON_API_GITHUB_PAT_TOKEN` | GitHub PAT token for artifact retrieval | `babylon-app` (build & runtime) |
| `/zenml` | `ZENML_SERVER_URL` | Endpoint for ZenML | `babylon-app` |
| | `ZENML_DEFAULT_USER_NAME` | Default ZenML admin username | `zenml` |
| | `ZENML_DEFAULT_USER_PASSWORD` | Default ZenML admin password | `zenml` |

---

## 3. Security Decisions & Best Practices

### 3.1 Least Privilege Pathing
* **Path-based access**: In production and staging, Machine Identities must be restricted using Infisical's ACL rules to only access their relevant paths. For instance, the `mongodb` service identity should only have access to `/database` and not `/integrations`.
* **Environment Isolation**: Production credentials must only be stored in the `prod` environment. Production machine clients will not have read permission for `dev` or `staging` environments.

### 3.2 Dynamic Secret Injection via CLI
* Using `infisical run` injects secrets directly as environment variables in-memory to the running container process.
* **No plaintext files**: Plaintext `.env` files are never written to disk within the production containers, preventing secret leakage through container compromises or file reads.
* Secrets are retrieved at container boot time directly from the local self-managed Infisical server.

### 3.3 Database Encryption
* The self-hosted Infisical instance encrypts all secret values in Postgres using the `ENCRYPTION_KEY`.
* **Important**: The `ENCRYPTION_KEY` and `AUTH_SECRET` must be backed up securely outside the stack. If they are lost, all stored secrets are unrecoverable.
