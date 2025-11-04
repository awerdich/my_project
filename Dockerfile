FROM python:3.12.10 AS base

# Install UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Ports for jupyter and tensorboard
EXPOSE 8888

RUN mkdir -p /app
WORKDIR /app

# Copy the project files to create the environment
COPY README.md .
COPY src/my_project/__init__.py src/cadence/__init__.py

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=.git,target=.git \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
     uv sync --frozen

# Copy bash scripts and set executable flags
RUN mkdir -p /run_scripts
COPY /bash_scripts/* /run_scripts
RUN chmod +x /run_scripts/*

# Run the jupyter server
CMD ["/bin/bash", "/run_scripts/docker_entry"]
