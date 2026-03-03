"""
Supabase client connection - اتصال عميل Supabase
"""

from functools import lru_cache
from config import get_settings

# Lazy import to allow running without supabase installed (for tests)
_client = None


def get_supabase_client():
    """Get or create Supabase client singleton."""
    global _client
    if _client is None:
        try:
            from supabase import create_client

            settings = get_settings()
            if settings.supabase_url and settings.supabase_service_role_key:
                _client = create_client(
                    settings.supabase_url,
                    settings.supabase_service_role_key,
                )
            else:
                _client = None
        except Exception:
            _client = None
    return _client
