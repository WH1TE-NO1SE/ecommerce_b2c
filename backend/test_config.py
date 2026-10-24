"""Configuration and authentication checks that do not connect to MySQL."""
import os
import subprocess
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

from settings import get_jwt_secret


class ConfigurationTests(unittest.TestCase):
    def test_environment_overrides_local_file_and_preserves_password(self):
        environment = dict(os.environ, MYSQL_USER="ci_user", MYSQL_PASS="a@b:/?#%$",
                           MYSQL_HOST="db.example", MYSQL_PORT="3307", MYSQL_DB="ci_db")
        script = """
from config import DATABASE_URL
assert DATABASE_URL.username == 'ci_user'
assert DATABASE_URL.password == 'a@b:/?#%$'
assert DATABASE_URL.host == 'db.example'
assert DATABASE_URL.port == 3307
assert DATABASE_URL.database == 'ci_db'
"""
        subprocess.run([sys.executable, "-c", script], env=environment,
                       cwd=Path(__file__).parent, check=True, capture_output=True)

    def test_missing_or_placeholder_jwt_secret_is_rejected(self):
        for secret in ["", "short", "replace-with-a-random-secret-of-at-least-32-characters"]:
            with self.subTest(secret=secret), patch.dict(os.environ, JWT_SECRET_KEY=secret):
                with self.assertRaises(RuntimeError):
                    get_jwt_secret()

    def test_token_round_trip_and_tamper_rejection(self):
        with patch.dict(os.environ, JWT_SECRET_KEY="test-only-secret-" * 4):
            from auth import create_access_token, decode_token
            from fastapi import HTTPException
            from jose import jwt

            token = create_access_token({"sub": "42"})
            self.assertEqual(decode_token(token)["sub"], "42")
            forged = jwt.encode({"sub": "42"}, "another-test-only-secret-" * 4, algorithm="HS256")
            with self.assertRaises(HTTPException) as error:
                decode_token(forged)
            self.assertEqual(error.exception.status_code, 401)


if __name__ == "__main__":
    unittest.main()
