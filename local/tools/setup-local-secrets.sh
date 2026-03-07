#!/bin/bash

# Script to initialize OpenBao with required secrets for local development.
# Run this from the project root.

export BAO_ADDR="http://localhost:8200"
export BAO_TOKEN="dev-token"

echo "Waiting for OpenBao to be ready..."
until curl -s "$BAO_ADDR/v1/sys/health" | grep '"initialized":true' > /dev/null; do
    echo "OpenBao not yet ready, waiting..."
    sleep 2
done

echo "OpenBao is ready. Enabling KV v2 secrets engine at 'secret/'..."
# Enable KV v2 at 'secret/' if not already enabled.
if ! curl -s --header "X-Bao-Token: $BAO_TOKEN" "$BAO_ADDR/v1/sys/mounts" | grep -q "secret/"; then
    # Explicitly set the address to http to avoid HTTPS errors
    docker compose -f local/docker-compose.yml exec openbao bao secrets enable -address=http://127.0.0.1:8200 -path=secret kv-v2
fi

echo "Writing database secrets to 'secret/test'..."
# The app is hardcoded to look for secrets at path 'test' under the default mount 'secret/'.
curl -s --header "X-Vault-Token: $BAO_TOKEN" --header "X-Bao-Token: $BAO_TOKEN" \
     --request POST \
     --data '{"data":{"DB_HOST":"postgres", "DB_PORT":"5432", "DB_USERNAME":"user", "DB_PASSWORD":"password"}}' \
     "$BAO_ADDR/v1/secret/data/test"

echo -e "\nVerifying secrets..."
curl -s --header "X-Vault-Token: $BAO_TOKEN" --header "X-Bao-Token: $BAO_TOKEN" \
     "$BAO_ADDR/v1/secret/data/test"

echo -e "\nSecrets setup complete."
