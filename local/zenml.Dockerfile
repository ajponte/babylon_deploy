# Use the official ZenML server image as the base.
# It includes the ZenML server, dashboard, and API.
FROM zenmldocker/zenml-server:latest

# Metadata about the image.
LABEL maintainer="babylon-team"
LABEL description="ZenML Server for RAG pipeline orchestration in Babylon"

# Set environment variables for the ZenML server.
# Defaults are fine for most cases, but we explicitly set them for clarity.
ENV ZENML_SERVER_HOST=0.0.0.0
ENV ZENML_SERVER_PORT=8080

# ZenML uses /zenml/storage as its default sqlite data directory.
# This directory should be persisted in a volume.
VOLUME ["/zenml/storage"]

# Expose the default ZenML server port.
EXPOSE 8080

# The base image's entrypoint and cmd already handle starting the server.
# CMD ["zenml", "server", "up", "--host", "0.0.0.0", "--port", "8080"]
