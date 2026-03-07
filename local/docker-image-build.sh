#!/bin/bash

set -e

# Define the image name and tag. You can change these to whatever you prefer.
IMAGE_NAME="babylon-app"
IMAGE_TAG="latest"

# Provide user feedback before starting the build.
echo "Building Docker image: $IMAGE_NAME:$IMAGE_TAG"

# The 'docker build' command builds an image from the Dockerfile in the current directory.
# The '-t' flag tags the image with the specified name and tag.
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Check the exit code of the last command to see if the build was successful.
if [ $? -eq 0 ]; then
  echo "Docker image built successfully! You can now run your container."
else
  echo "Docker image build failed."
  # Exit the script with an error code if the build fails.
  exit 1
fi
