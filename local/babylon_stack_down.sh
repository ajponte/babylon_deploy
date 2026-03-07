#!/bin/bash
# Script to bring down the Docker Compose stack.

echo "Bringing down the Babylon Docker Compose stack..."
docker compose down

if [ $? -eq 0 ]; then
    echo "Babylon Docker Compose stack stopped and removed successfully."
else
    echo "Error stopping Babylon Docker Compose stack."
    exit 1
fi
