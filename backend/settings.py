"""Shared backend and seed configuration, loaded from backend/.env or the environment."""
import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).with_name(".env"), override=False)

MYSQL_USER = os.environ.get("MYSQL_USER", "root")
MYSQL_PASS = os.environ.get("MYSQL_PASS", "")
MYSQL_HOST = os.environ.get("MYSQL_HOST", "127.0.0.1")
MYSQL_PORT = int(os.environ.get("MYSQL_PORT", "3306"))
MYSQL_DB = os.environ.get("MYSQL_DB", "ecommerce_b2c")


def get_jwt_secret() -> str:
    secret = os.environ.get("JWT_SECRET_KEY", "")
    if len(secret) < 32 or secret == "replace-with-a-random-secret-of-at-least-32-characters":
        raise RuntimeError("Set JWT_SECRET_KEY to a random secret of at least 32 characters in backend/.env.")
    return secret
