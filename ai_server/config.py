"""Application configuration - إعدادات التطبيق"""

import os
from functools import lru_cache

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings

# Minimum length required for JWT_SECRET. HS256 requires >= 32 bytes to be
# considered secure; anything shorter is rejected at startup.
MIN_JWT_SECRET_LENGTH = 32


class Settings(BaseSettings):
    """Server settings loaded from environment variables."""

    # Supabase - MUST be set via environment variables
    supabase_url: str = ""
    supabase_anon_key: str = ""
    supabase_service_role_key: str = ""

    # JWT
    jwt_secret: str = ""
    jwt_audience: str = "authenticated"

    # OpenAI
    openai_api_key: str = ""

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = False

    # CORS - configurable via ALLOWED_ORIGINS env var (comma-separated)
    allowed_origins: str = ""

    @property
    def cors_origins(self) -> list[str]:
        if self.allowed_origins:
            return [o.strip() for o in self.allowed_origins.split(",") if o.strip()]
        # Fallback defaults for development only
        return [
            "http://localhost:3000",
            "http://localhost:8080",
        ]

    # ------------------------------------------------------------------
    # Startup validators - refuse to boot with unsafe configuration.
    # Skipped only when ALHAI_SKIP_STARTUP_VALIDATION=1 (for legacy tests
    # that build Settings() directly without real credentials).
    # ------------------------------------------------------------------
    @field_validator("jwt_secret")
    @classmethod
    def _validate_jwt_secret(cls, value: str) -> str:
        if os.environ.get("ALHAI_SKIP_STARTUP_VALIDATION") == "1":
            return value
        if value is None or not value.strip():
            raise RuntimeError(
                "JWT_SECRET is empty. Set JWT_SECRET to the Supabase JWT signing "
                "secret (must be at least 32 characters)."
            )
        if len(value.strip()) < MIN_JWT_SECRET_LENGTH:
            raise RuntimeError(
                f"JWT_SECRET is too short ({len(value.strip())} chars). "
                f"Must be at least {MIN_JWT_SECRET_LENGTH} characters."
            )
        return value

    @field_validator("supabase_url")
    @classmethod
    def _validate_supabase_url(cls, value: str) -> str:
        if os.environ.get("ALHAI_SKIP_STARTUP_VALIDATION") == "1":
            return value
        if not value or not value.strip():
            raise RuntimeError(
                "SUPABASE_URL is missing. Set SUPABASE_URL to your Supabase "
                "project URL (must start with https://)."
            )
        if not value.startswith("https://"):
            raise RuntimeError(
                f"SUPABASE_URL must start with 'https://'. Got: {value!r}"
            )
        return value

    @model_validator(mode="after")
    def _validate_service_role_key(self) -> "Settings":
        if os.environ.get("ALHAI_SKIP_STARTUP_VALIDATION") == "1":
            return self
        # Only enforce non-empty when the field is *set* via env/.env — if it
        # was left at the default empty string we let the server start for
        # local development, but if someone passes a whitespace-only value
        # we reject it.
        key = self.supabase_service_role_key
        if key is not None and key != "" and not key.strip():
            raise RuntimeError(
                "SUPABASE_SERVICE_ROLE_KEY is set but whitespace-only. "
                "Either unset it or provide a real key."
            )
        return self

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
