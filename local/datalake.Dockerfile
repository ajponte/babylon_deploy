# Use the official MongoDB image as the base.
# Using a specific version is recommended for production, but 'latest' is fine for local development.
FROM mongo:latest

# The base image already handles the entrypoint and default command,
# so no further configuration is needed for a basic setup.
# You could add custom scripts or configuration files here if needed.
