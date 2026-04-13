"""Application configuration - إعدادات التطبيق"""

from functools import lru_cache

from pydantic_settings import BaseSettings


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

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
