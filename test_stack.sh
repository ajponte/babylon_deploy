#!/bin/bash
# Script to run tests on the Babylon Docker stack.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="${SCRIPT_DIR}/local"

echo "Running tests on the Babylon Docker stack..."

cd "${LOCAL_DIR}"

bash test_bao.sh
