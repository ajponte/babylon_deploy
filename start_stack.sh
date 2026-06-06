#!/bin/bash
# Script to build and start the Babylon Docker stack.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="${SCRIPT_DIR}/local"

echo "Building and starting the Babylon Docker stack..."

cd "${LOCAL_DIR}"

bash babylon_stack_start.sh

# Initialize secrets in Infisical for local development.
if [ -f "${SCRIPT_DIR}/local/tools/setup-local-infisical.sh" ]; then
    echo "Initializing local secrets in Infisical..."
    bash "${SCRIPT_DIR}/local/tools/setup-local-infisical.sh"
fi

