#!/bin/bash
# Script to build and start the Babylon Docker stack.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="${SCRIPT_DIR}/local"

echo "Building and starting the Babylon Docker stack..."

cd "${LOCAL_DIR}"

bash babylon_stack_start.sh

# Initialize secrets in OpenBao for local development.
if [ -f "${SCRIPT_DIR}/local/tools/setup-local-secrets.sh" ]; then
    echo "Initializing local secrets in OpenBao..."
    bash "${SCRIPT_DIR}/local/tools/setup-local-secrets.sh"
fi

