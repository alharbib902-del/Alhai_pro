"""Application configuration - إعدادات التطبيق"""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Server settings loaded from environment variables."""

    # Supabase - MUST be set via environment variables
    supabase_url: str = ""
    supabase_anon_key: str = ""
    supabase_service_role_key: str = ""

    # JWT
    jwt_secret: str = ""

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = False

    # CORS
    allowed_origins: str = "http://localhost:3000,http://localhost:8080"

    @property
    def cors_origins(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",")]

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
