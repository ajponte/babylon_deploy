#!/bin/bash

set -e

# This script runs a Docker container from an image.
# It now takes five arguments and reads environment variables from a .env file.
#
# Arguments:
# 1. Image Repository (e.g., 'my-flask-app')
# 2. Image Tag (e.g., 'latest')
# 3. Image ID (the unique hash of the image)
# 4. Host Port (the port on your local machine, e.g., '5000')
# 5. Container Port (the port the application runs on inside the container, e.g., '8000')
#
# Assumes a .env file is in the same directory.

# Check if the correct number of arguments are provided.
if [ "$#" -ne 5 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 <image_repository> <image_tag> <image_id> <host_port> <container_port>"
    exit 1
fi

# Assign the input arguments to variables for clarity.
IMAGE_REPO=$1
IMAGE_TAG=$2
IMAGE_ID=$3
HOST_PORT=$4
CONTAINER_PORT=$5
FULL_IMAGE_NAME="${IMAGE_REPO}:${IMAGE_TAG}"

# Define the .env file path.
ENV_FILE=".env"
ENV_ARGS=""

# Check if the .env file exists and read its contents.
if [ ! -f "$ENV_FILE" ]; then
    echo "Warning: .env file not found. Skipping environment variable loading."
else
    echo "Reading environment variables from .env file..."
    # Loop through each line of the .env file.
    while IFS= read -r line; do
        # Ignore comments (#) and empty lines.
        if [[ ! "$line" =~ ^# && -n "$line" ]]; then
            # Add the -e flag for each variable to be passed to Docker.
            ENV_ARGS+=" -e $line"
        fi
    done < "$ENV_FILE"
fi

echo "Attempting to run Docker image:"
echo "  Repository: ${IMAGE_REPO}"
echo "  Tag: ${IMAGE_TAG}"
echo "  Image ID: ${IMAGE_ID}"
echo "  Host Port: ${HOST_PORT}"
echo "  Container Port: ${CONTAINER_PORT}"

# Optional: Stop and remove any existing container with the same name to prevent conflicts.
EXISTING_CONTAINER_NAME="${IMAGE_REPO}-${IMAGE_TAG}"
echo "Checking for existing container '${EXISTING_CONTAINER_NAME}'..."
if docker ps -a --format '{{.Names}}' | grep -q "${EXISTING_CONTAINER_NAME}"; then
    echo "  Container '${EXISTING_CONTAINER_NAME}' found. Stopping and removing it..."
    docker stop "${EXISTING_CONTAINER_NAME}" > /dev/null
    docker rm "${EXISTING_CONTAINER_NAME}" > /dev/null
fi

# Run the Docker container in detached mode (-d), map the specified ports, and give it a name.
# The `ENV_ARGS` variable is now included to pass the environment variables.
echo "Running container from image ${FULL_IMAGE_NAME}..."
# Using `eval` to handle the dynamic `ENV_ARGS` string correctly.
eval docker run -d -p "${HOST_PORT}:${CONTAINER_PORT}" --name "${EXISTING_CONTAINER_NAME}" ${ENV_ARGS} "${FULL_IMAGE_NAME}"

# Check the exit status of the docker run command.
if [ $? -eq 0 ]; then
    echo "Container '${EXISTING_CONTAINER_NAME}' is running successfully!"
else
    echo "Failed to run container."
    exit 1
fi
