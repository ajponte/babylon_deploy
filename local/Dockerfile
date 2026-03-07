# Use a slim version of the official Python 3.13 image as a base.
FROM python:3.13-slim

# Set the working directory in the container.
WORKDIR /usr/src/app

# Accept the GitHub PAT token as a build argument.
ARG BABYLON_API_GITHUB_PAT_TOKEN
ENV BABYLON_API_GITHUB_PAT_TOKEN=$BABYLON_API_GITHUB_PAT_TOKEN

# Install curl, unzip, and tar.
RUN apt-get update && apt-get install -y curl unzip tar && rm -rf /var/lib/apt/lists/*

# Download the latest artifact of the application itself.
RUN curl -L -H "Authorization: token $BABYLON_API_GITHUB_PAT_TOKEN" \
    -o babylon.zip https://github.com/ajponte/babylon/releases/download/latest/babylon.zip

# Unzip and Untar the application source code.
RUN unzip babylon.zip && \
    tar -xzf server-0.1.0.tar.gz --strip-components=1 && \
    rm babylon.zip server-0.1.0.tar.gz *.tar *.whl

# Copy production script from local context.
# Using babylon_app-LOCAL.py as renamed by the user.
COPY babylon_app-LOCAL.py production.py

# Copy the artifact download script from the local tools directory.
COPY tools/github_artifacts.py github_artifacts.py

# Install dependencies needed for the artifact download script.
RUN pip install requests

# Use github_artifacts.py to download the OpenAPI spec from the babylon_api_spec repo.
# The script expects BABYLON_API_GITHUB_PAT_TOKEN to be set.
RUN python github_artifacts.py --repo ajponte/babylon_api_spec

# Debug and restructure the api_spec directory.
RUN find api_spec -name "*.yml" -exec cp {} api_spec/babylon-api-spec.yml \; && \
    ls -la api_spec/babylon-api-spec.yml

# Install poetry.
RUN pip install poetry && poetry config virtualenvs.create false

# Install the application dependencies.
RUN poetry install --without test --no-root --no-ansi

# Expose port 8000.
EXPOSE 8000

# Using gunicorn to run the application.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "production:application"]
