"""Application configuration - إعدادات التطبيق"""

import os
from functools import lru_cache

from pydantic import SecretStr, field_validator, model_validator
from pydantic_settings import BaseSettings

# Minimum length required for JWT_SECRET. HS256 requires >= 32 bytes to be
# considered secure; anything shorter is rejected at startup.
MIN_JWT_SECRET_LENGTH = 32


def _as_plain(value) -> str:
    """Return a plain string regardless of whether `value` is str or SecretStr."""
    if value is None:
        return ""
    if hasattr(value, "get_secret_value"):
        return value.get_secret_value() or ""
    return str(value)


class Settings(BaseSettings):
    """Server settings loaded from environment variables."""

    # Supabase - MUST be set via environment variables
    supabase_url: str = ""
    supabase_anon_key: str = ""
    # Service role key is a secret — wrap in SecretStr so it doesn't leak into
    # logs or `repr(settings)` output.
    supabase_service_role_key: SecretStr = SecretStr("")

    # JWT
    jwt_secret: SecretStr = SecretStr("")
    jwt_audience: str = "authenticated"

    # OpenAI
    openai_api_key: SecretStr = SecretStr("")

    # Redis (optional). Empty string = cache disabled.
    # Example: redis://localhost:6379/0
    redis_url: str = ""

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = False

    # CORS - configurable via ALLOWED_ORIGINS env var (comma-separated)
    allowed_origins: str = ""

    # Host header validation (TrustedHostMiddleware). Comma-separated.
    # Leave empty to disable the middleware (e.g. for local development).
    allowed_hosts: str = ""

    @property
    def cors_origins(self) -> list[str]:
        if self.allowed_origins:
            return [o.strip() for o in self.allowed_origins.split(",") if o.strip()]
        # Fallback defaults for development only. In production, ALLOWED_ORIGINS
        # MUST be set — the model_validator below enforces this when debug=False.
        return [
            "http://localhost:3000",
            "http://localhost:8080",
        ]

    @property
    def trusted_hosts(self) -> list[str]:
        """Parsed ALLOWED_HOSTS. Empty list disables the middleware."""
        if not self.allowed_hosts:
            return []
        return [h.strip() for h in self.allowed_hosts.split(",") if h.strip()]

    # ------------------------------------------------------------------
    # Startup validators - refuse to boot with unsafe configuration.
    # Skipped only when ALHAI_SKIP_STARTUP_VALIDATION=1 (for legacy tests
    # that build Settings() directly without real credentials).
    # ------------------------------------------------------------------
    @field_validator("jwt_secret", mode="before")
    @classmethod
    def _validate_jwt_secret(cls, value) -> str:
        if os.environ.get("ALHAI_SKIP_STARTUP_VALIDATION") == "1":
            return _as_plain(value)
        raw = _as_plain(value)
        if not raw or not raw.strip():
            raise RuntimeError(
                "JWT_SECRET is empty. Set JWT_SECRET to the Supabase JWT signing "
                "secret (must be at least 32 characters)."
            )
        if len(raw.strip()) < MIN_JWT_SECRET_LENGTH:
            raise RuntimeError(
                f"JWT_SECRET is too short ({len(raw.strip())} chars). "
                f"Must be at least {MIN_JWT_SECRET_LENGTH} characters."
            )
        return raw

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

    @field_validator("supabase_service_role_key", mode="before")
    @classmethod
    def _validate_service_role_key_str(cls, value) -> str:
        # Reject whitespace-only values; allow empty (local dev).
        raw = _as_plain(value)
        if raw != "" and not raw.strip():
            raise RuntimeError(
                "SUPABASE_SERVICE_ROLE_KEY is set but whitespace-only. "
                "Either unset it or provide a real key."
            )
        return raw

    @model_validator(mode="after")
    def _validate_production_config(self) -> "Settings":
        """Additional production-only checks that depend on multiple fields.

        Only runs when ALHAI_ENFORCE_PRODUCTION=1 is set — production deploys
        (Railway / Render) should set this flag so that missing configuration
        fails fast at boot. Unit tests that build Settings directly don't need
        to set ALLOWED_ORIGINS.
        """
        if os.environ.get("ALHAI_SKIP_STARTUP_VALIDATION") == "1":
            return self
        if os.environ.get("ALHAI_ENFORCE_PRODUCTION") != "1":
            return self
        if not self.debug:
            # In production we require an explicit ALLOWED_ORIGINS — the
            # localhost fallback above is for development only.
            if not self.allowed_origins or not self.allowed_origins.strip():
                raise RuntimeError(
                    "ALLOWED_ORIGINS must be set in production (DEBUG=false). "
                    "Provide a comma-separated list of allowed frontend origins."
                )
        return self

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
