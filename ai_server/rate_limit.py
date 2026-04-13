"""
Per-endpoint rate limiting configuration.

Heavy endpoints (image recognition, chat, reports) get stricter limits.
Light endpoints (forecast, pricing, etc.) get standard limits.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])

# Rate limit strings for different endpoint categories
RATE_STANDARD = "60/minute"      # Standard AI endpoints
RATE_HEAVY = "20/minute"         # Heavy endpoints (image processing, OpenAI calls)
RATE_CHAT = "30/minute"          # Chat/assistant endpoints (OpenAI calls)
RATE_HEALTH = "120/minute"       # Health check (lightweight)
