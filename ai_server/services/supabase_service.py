"""
Supabase data service - خدمة بيانات Supabase
Read data from Supabase for ML processing.
"""

from models.database import get_supabase_client


class SupabaseService:
    """Service to read data from Supabase for AI processing."""

    @staticmethod
    def get_sales(org_id: str, store_id: str, days: int = 30) -> list[dict]:
        """Get recent sales data."""
        client = get_supabase_client()
        if client is None:
            return []
        try:
            result = (
                client.table("sales")
                .select("*")
                .eq("org_id", org_id)
                .eq("store_id", store_id)
                .order("created_at", desc=True)
                .limit(1000)
                .execute()
            )
            return result.data or []
        except Exception:
            return []

    @staticmethod
    def get_products(org_id: str, store_id: str) -> list[dict]:
        """Get products data filtered by org_id AND store_id."""
        client = get_supabase_client()
        if client is None:
            return []
        try:
            result = (
                client.table("products")
                .select("*")
                .eq("org_id", org_id)
                .eq("store_id", store_id)
                .execute()
            )
            return result.data or []
        except Exception:
            return []

    @staticmethod
    def get_customers(org_id: str, store_id: str) -> list[dict]:
        """Get customers (accounts) data filtered by org_id AND store_id."""
        client = get_supabase_client()
        if client is None:
            return []
        try:
            result = (
                client.table("accounts")
                .select("*")
                .eq("org_id", org_id)
                .eq("store_id", store_id)
                .eq("type", "receivable")
                .execute()
            )
            return result.data or []
        except Exception:
            return []

    @staticmethod
    def get_employees(org_id: str, store_id: str) -> list[dict]:
        """Get employees data filtered by org_id AND store_id."""
        client = get_supabase_client()
        if client is None:
            return []
        try:
            result = (
                client.table("users")
                .select("*")
                .eq("org_id", org_id)
                .eq("store_id", store_id)
                .execute()
            )
            return result.data or []
        except Exception:
            return []

    @staticmethod
    def get_sale_items(org_id: str, store_id: str, limit: int = 5000) -> list[dict]:
        """Get sale items for basket analysis."""
        client = get_supabase_client()
        if client is None:
            return []
        try:
            result = (
                client.table("sale_items")
                .select("*, sales!inner(org_id, store_id)")
                .eq("sales.org_id", org_id)
                .eq("sales.store_id", store_id)
                .limit(limit)
                .execute()
            )
            return result.data or []
        except Exception:
            return []
