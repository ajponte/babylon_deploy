#!/bin/bash

# A simple shell script to test the OpenBao container.
# This script assumes the OpenBao server is running via docker-compose.

# The address of the OpenBao server inside the Docker network.
export BAO_ADDR="http://localhost:8200"

# The root token for the dev server, as defined in your docker-compose.yml.
export BAO_TOKEN="dev-token"

# Define the secret path and data.
SECRET_PATH="test/data/my-app-secret" # Note the /data in the path for kv-v2 secrets engine
SECRET_KEY="database_password"
SECRET_VALUE="super-secret-password-123"

echo "Waiting for OpenBao to be ready..."
# Use a loop to wait for the OpenBao server to respond.
# This ensures the script doesn't fail if OpenBao is still starting up.
until curl -s "$BAO_ADDR/v1/sys/health" | grep '"initialized":true' > /dev/null; do
    echo "OpenBao not yet ready, waiting..."
    sleep 2
done

echo "OpenBao is initialized and ready!"
echo "---"

# Check if the secrets engine at "test" is already enabled.
echo "Checking for 'test' secrets engine..."
if ! curl -s --header "X-Bao-Token: $BAO_TOKEN" "$BAO_ADDR/v1/sys/mounts" | grep -q "test/"; then
    echo "Secrets engine at 'test/' not found. Enabling it now..."
    # Enable the kv-v2 secrets engine at the specified path.
    docker compose exec openbao openbao secrets enable -path=test kv-v2
    if [ $? -ne 0 ]; then
        echo "Failed to enable secrets engine. Please check your docker-compose setup."
        exit 1
    fi
    echo "Secrets engine enabled successfully!"
fi

# Step 1: Add a secret to the 'test' path using a curl POST request.
echo "Writing a secret to path: $SECRET_PATH"
curl --header "X-Bao-Token: $BAO_TOKEN" \
     --request POST \
     --data "{\"data\":{\"$SECRET_KEY\":\"$SECRET_VALUE\"}}" \
     "$BAO_ADDR/v1/$SECRET_PATH"

# Note: We cannot easily check the exit status of curl for API success.
# You would need to parse the JSON response for errors.

echo "---"

# Step 2: Retrieve the secret from the 'test' path using a curl GET request.
echo "Retrieving secret from path: $SECRET_PATH"
curl --header "X-Bao-Token: $BAO_TOKEN" \
     --request GET \
     "$BAO_ADDR/v1/$SECRET_PATH"

echo "---"
echo "OpenBao test complete."
