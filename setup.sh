#!/usr/bin/env bash
set -e
uv add loguru google-cloud-bigquery google-cloud-secret-manager google-cloud-storage python-dotenv fastapi uvicorn gunicorn pydantic pydantic-settings pydantic[email]
