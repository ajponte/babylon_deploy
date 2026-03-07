# Use a slim version of the official Python 3.13 image as a base.
FROM python:3.13-slim

# Set the working directory in the container.
WORKDIR /usr/src/app

# Copy the dependency management files first.
COPY pyproject.toml poetry.lock ./

# Copy the .env file so it can be used by the application at runtime.
COPY .env .

# Install poetry.
RUN pip install poetry

# Install the dependencies and create a virtual environment within the container.
RUN poetry install --without test --no-root --sync --no-ansi

# Copy the rest of your application code into the container.
COPY . .

# Expose port 8000.
EXPOSE 8000

# Set the entrypoint for the container to use poetry's executable.
ENTRYPOINT ["poetry", "run"]

# The command to run your application using gunicorn.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "production:application"]
