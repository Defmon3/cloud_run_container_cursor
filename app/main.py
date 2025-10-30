#!/usr/bin/env python3
# /// script
# requires-python = "==3.12.9"
# dependencies = [
#     "loguru",
#     "google-cloud-bigquery",
#     "google-cloud-secret-manager",
#     "google-cloud-storage",
#     "python-dotenv",
#     "fastapi",
#     "uvicorn",
#     "gunicorn",
#     "pydantic",
#     "pydantic[email]",
#     "pydantic-settings",
# ]
# ///

"""
SPDX-License-Identifier: LicenseRef-NonCommercial-Only
© 2025 github.com/defmon3 — Non-commercial use only. Commercial use requires permission.
File: main.py
"""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from typing import Dict

from fastapi import FastAPI

from config import settings


@asynccontextmanager
async def lifespan(*_) -> AsyncGenerator[None, None]:
    """
    FastAPI lifespan context manager for starting and stopping the Telegram bot.
    :yield: None
    """
    yield


app = FastAPI(title=settings.service_name, lifespan=lifespan)


@app.get("/")
async def root() -> Dict[str, str]:
    """
    Health check endpoint.
    :return: A dictionary indicating the service status.
    :rtype: Dict[str, str]
    """
    return {"status": "ok"}
