# Stage 1: Base Image and Install uv
FROM python:3.12-slim AS base

# Set environment variables
ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PYTHONUNBUFFERED=1 \
    UV_CACHE_DIR=/var/cache/uv

# Install uv using pip
# hadolint ignore=DL3013
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install uv

# Stage 2: Build Dependencies
FROM base AS builder

WORKDIR /app

# Create a non-root user
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser

# Copy dependency definition files
COPY pyproject.toml uv.lock project.env ./

# Install dependencies using uv pip install. It reads pyproject.toml, # <-- CHANGE IS HERE
# uses uv.lock for locked versions, and --system installs globally.
# Mount uv cache from the base stage and persist it
RUN --mount=type=cache,target=/var/cache/uv \
    uv pip install . --system --no-cache # <-- Use 'uv pip install .'

# Stage 3: Final Application Image
FROM base AS final

WORKDIR /app

# Create a non-root user (repeat from builder stage if needed, ensures consistency)
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser

# Copy installed dependencies from the builder stage's system site-packages
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code and necessary config files
# Ensure ownership is set for the appuser
COPY --chown=appuser:appuser app/ ./

USER appuser
# Set default PORT environment variable (can be overridden at runtime)
ENV PORT=8080

# Command to run the application using uvicorn
# Use exec form for proper signal handling. Use sh -c to allow env var expansion.
# Need to ensure uvicorn is found in the path copied from builder stage.
# Use exec to replace the shell process with the uvicorn process
CMD ["sh", "-c", "exec uvicorn main:app --host 0.0.0.0 --port $PORT"]