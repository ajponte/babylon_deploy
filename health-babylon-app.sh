#!/bin/bash

# Script to check the health of the babylon-app service.
# The app is mapped to port 5001 on the host.

echo "Checking babylon-app health..."
curl -f http://localhost:5001/health

if [ $? -eq 0 ]; then
    echo -e "\n[SUCCESS] Babylon App is healthy!"
    exit 0
else
    echo -e "\n[FAILURE] Babylon App health check failed."
    exit 1
fi
