#!/bin/bash

# setup-local-infisical.sh
# Automate bootstrapping, configuration, and seeding of local self-hosted Infisical.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="${LOCAL_DIR}/.env"

echo "Using env file: $ENV_FILE"

# 1. Check or generate INFISICAL_ENCRYPTION_KEY and INFISICAL_AUTH_SECRET
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

UPDATED_ENV=false

if [ -z "$INFISICAL_ENCRYPTION_KEY" ]; then
    echo "Generating INFISICAL_ENCRYPTION_KEY..."
    INFISICAL_ENCRYPTION_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    UPDATED_ENV=true
fi

if [ -z "$INFISICAL_AUTH_SECRET" ]; then
    echo "Generating INFISICAL_AUTH_SECRET..."
    INFISICAL_AUTH_SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    UPDATED_ENV=true
fi

if [ "$UPDATED_ENV" = true ]; then
    echo "Writing initial encryption key and auth secret to $ENV_FILE..."
    mkdir -p "$(dirname "$ENV_FILE")"
    cat <<EOF > "$ENV_FILE"
INFISICAL_ENCRYPTION_KEY=$INFISICAL_ENCRYPTION_KEY
INFISICAL_AUTH_SECRET=$INFISICAL_AUTH_SECRET
EOF
    # We must restart/up the Infisical container to pick up these keys, otherwise it will run with empty keys
    echo "Restarting Infisical to apply newly generated encryption/auth keys..."
    docker compose -f "${LOCAL_DIR}/docker-compose.yml" up -d infisical infisical-redis postgres
fi

# 2. Check if already bootstrapped and credentials exist
if [ -n "$INFISICAL_CLIENT_ID" ] && [ -n "$INFISICAL_CLIENT_SECRET" ] && [ -n "$INFISICAL_PROJECT_ID" ]; then
    echo "Infisical client credentials already present in local/.env. Checking if stack needs updating..."
    docker compose -f "${LOCAL_DIR}/docker-compose.yml" up -d
    echo "Infisical stack is already configured and running."
    exit 0
fi

# Wait for Infisical API to be ready
echo "Waiting for Infisical API to be ready..."
until curl -s -f http://localhost:8201/api/status > /dev/null; do
    echo "Infisical not yet ready, waiting..."
    sleep 2
done
echo "Infisical API is ready."

# 3. Bootstrap Infisical admin user
echo "Bootstrapping Infisical admin instance..."
BOOTSTRAP_PAYLOAD='{"email": "admin@babylon.local", "password": "BabylonPassword123!", "organization": "babylon"}'

BOOTSTRAP_RESP=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$BOOTSTRAP_PAYLOAD" \
  http://localhost:8201/api/v1/admin/bootstrap)

ADMIN_TOKEN=$(echo "$BOOTSTRAP_RESP" | jq -r '.identity.credentials.token // empty')
ORG_ID=$(echo "$BOOTSTRAP_RESP" | jq -r '.organization.id // empty')

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" = "null" ]; then
    echo "Bootstrap response did not return token. Response: $BOOTSTRAP_RESP"
    echo "Error: Infisical database may already be bootstrapped but local/.env is missing credentials."
    echo "To reset database and start clean, run: docker compose down -v"
    exit 1
fi

echo "Successfully bootstrapped admin. Org ID: $ORG_ID"

# 4. Create Project 'babylon'
echo "Creating project 'babylon'..."
PROJECT_RESP=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"projectName": "babylon"}' \
  http://localhost:8201/api/v1/projects)

PROJECT_ID=$(echo "$PROJECT_RESP" | jq -r '.project.id // empty')
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
    echo "Failed to create project. Response: $PROJECT_RESP"
    exit 1
fi
echo "Created project with ID: $PROJECT_ID"

# 5. Create Machine Identity 'babylon-app'
echo "Creating Machine Identity 'babylon-app'..."
IDENTITY_RESP=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"name\": \"babylon-app\", \"organizationId\": \"$ORG_ID\"}" \
  http://localhost:8201/api/v1/identities)

IDENTITY_ID=$(echo "$IDENTITY_RESP" | jq -r '.identity.id // empty')
if [ -z "$IDENTITY_ID" ] || [ "$IDENTITY_ID" = "null" ]; then
    echo "Failed to create Machine Identity. Response: $IDENTITY_RESP"
    exit 1
fi
echo "Created Machine Identity with ID: $IDENTITY_ID"

# 6. Attach Machine Identity to the project with the admin role
echo "Attaching Machine Identity to project memberships..."
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"roles": [{"role": "admin", "isTemporary": false}]}' \
  "http://localhost:8201/api/v1/projects/$PROJECT_ID/memberships/identities/$IDENTITY_ID" > /dev/null

# 7. Retrieve the Client ID for Universal Auth
echo "Retrieving Universal Auth Client ID..."
CLIENT_RESP=$(curl -s -X GET \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  "http://localhost:8201/api/v1/auth/universal-auth/identities/$IDENTITY_ID")

CLIENT_ID=$(echo "$CLIENT_RESP" | jq -r '.identityUniversalAuth.clientId // empty')
if [ -z "$CLIENT_ID" ] || [ "$CLIENT_ID" = "null" ]; then
    echo "Failed to retrieve Client ID. Response: $CLIENT_RESP"
    exit 1
fi
echo "Retrieved Client ID: $CLIENT_ID"

# 8. Generate a Client Secret
echo "Generating Universal Auth Client Secret..."
SECRET_RESP=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"description": "local dev client secret", "numUsesLimit": 0, "ttl": 0}' \
  "http://localhost:8201/api/v1/auth/universal-auth/identities/$IDENTITY_ID/client-secrets")

CLIENT_SECRET=$(echo "$SECRET_RESP" | jq -r '.clientSecret // empty')
if [ -z "$CLIENT_SECRET" ] || [ "$CLIENT_SECRET" = "null" ]; then
    echo "Failed to generate Client Secret. Response: $SECRET_RESP"
    exit 1
fi
echo "Generated Client Secret successfully."

# 9. Seed the development secrets in the dev environment at path /
echo "Seeding development secrets..."
secrets=("DB_HOST=postgres" "DB_PORT=5432" "DB_USERNAME=user" "DB_PASSWORD=password")

for s in "${secrets[@]}"; do
    key="${s%%=*}"
    val="${s#*=}"
    echo "Seeding $key..."
    curl -s -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -d "{\"projectId\": \"$PROJECT_ID\", \"environment\": \"dev\", \"secretValue\": \"$val\", \"secretPath\": \"/\", \"type\": \"shared\"}" \
      "http://localhost:8201/api/v4/secrets/$key" > /dev/null
done
echo "Seeded database secrets successfully."

# 10. Write final credentials to local/.env
echo "Writing final configuration to $ENV_FILE..."
cat <<EOF > "$ENV_FILE"
INFISICAL_ENCRYPTION_KEY=$INFISICAL_ENCRYPTION_KEY
INFISICAL_AUTH_SECRET=$INFISICAL_AUTH_SECRET
INFISICAL_PROJECT_ID=$PROJECT_ID
INFISICAL_CLIENT_ID=$CLIENT_ID
INFISICAL_CLIENT_SECRET=$CLIENT_SECRET
EOF

# 11. Run docker compose up -d to recreate services with the new environment variables
echo "Re-applying Docker Compose stack to hook up Machine Identity credentials..."
docker compose -f "${LOCAL_DIR}/docker-compose.yml" up -d

echo "Infisical bootstrap and seeding complete."
