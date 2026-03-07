#!/bin/bash
# Script to bring up the Docker Compose stack without pulling images.

echo "Stopping and removing existing containers..."
docker compose down

echo "Forcing a clean rebuild of the babylon-app image..."
docker compose build --no-cache

echo "Bringing up the Babylon Docker Compose stack..."
docker compose up -d

if [ $? -eq 0 ]; then
    echo "Babylon Docker Compose stack started successfully in detached mode."
else
    echo "Error starting Babylon Docker Compose stack."
    exit 1
fi