#!/usr/bin/env python3
"""
post_deploy_check.py

Smoke test that verifies the 2026-04-17 migration set (v38..v42) landed
correctly on the target Supabase database. Run AFTER deploy_migrations.sh
and (optionally) validate_constraints.sh.

Checks performed:
  1. sa_audit_log table exists with the v40 shape (actor_id UUID etc).
  2. daily_summaries has total_refunds_count (v39).
  3. invoices has the ZATCA CHECK constraint (v38).
  4. Each enum-guarded table has its v41 CHECK constraint.
  5. sync_version column present on 10 bidirectional-sync tables (v42).
  6. The sync_version_bump() trigger function exists.
  7. RLS is enabled on sa_audit_log.

Usage:
  export SUPABASE_DB_URL="..."
  python3 scripts/post_deploy_check.py

Exit codes:
  0 = all checks pass
  1 = one or more checks failed (see output)
  2 = environment problem (missing URL or psycopg2)
"""
from __future__ import annotations

import os
import sys
from typing import Callable

try:
    import psycopg2  # type: ignore
    from psycopg2.extras import RealDictCursor  # type: ignore
except ImportError:
    print("ERROR: psycopg2 not installed. Install with: pip install psycopg2-binary")
    sys.exit(2)


GREEN = "\033[0;32m"
RED = "\033[0;31m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"


def ok(msg: str) -> None:
    print(f"{GREEN}[ PASS ]{NC} {msg}")


def fail(msg: str) -> None:
    print(f"{RED}[ FAIL ]{NC} {msg}")


def info(msg: str) -> None:
    print(f"{BLUE}[ info ]{NC} {msg}")


def warn(msg: str) -> None:
    print(f"{YELLOW}[ warn ]{NC} {msg}")


class Checker:
    def __init__(self, conn) -> None:
        self.conn = conn
        self.passed = 0
        self.failed = 0
        self.skipped = 0

    def run(self, name: str, check: Callable[[], bool]) -> None:
        try:
            if check():
                ok(name)
                self.passed += 1
            else:
                fail(name)
                self.failed += 1
        except psycopg2.errors.UndefinedTable:
            warn(f"{name} — skipped (table not in this project)")
            self.skipped += 1
            self.conn.rollback()
        except Exception as e:
            fail(f"{name} — ERROR: {e}")
            self.failed += 1
            self.conn.rollback()

    def summary(self) -> int:
        print()
        total = self.passed + self.failed + self.skipped
        print(f"  Passed:  {self.passed}/{total}")
        print(f"  Failed:  {self.failed}/{total}")
        print(f"  Skipped: {self.skipped}/{total}")
        return 1 if self.failed else 0


def has_table(cur, name: str) -> bool:
    cur.execute(
        "SELECT 1 FROM information_schema.tables "
        "WHERE table_schema='public' AND table_name=%s",
        (name,),
    )
    return cur.fetchone() is not None


def has_column(cur, table: str, column: str) -> bool:
    cur.execute(
        "SELECT 1 FROM information_schema.columns "
        "WHERE table_schema='public' AND table_name=%s AND column_name=%s",
        (table, column),
    )
    return cur.fetchone() is not None


def has_constraint(cur, table: str, constraint: str) -> bool:
    cur.execute(
        "SELECT 1 FROM pg_constraint c "
        "JOIN pg_class t ON t.oid = c.conrelid "
        "JOIN pg_namespace n ON n.oid = t.relnamespace "
        "WHERE n.nspname='public' AND t.relname=%s AND c.conname=%s",
        (table, constraint),
    )
    return cur.fetchone() is not None


def has_function(cur, name: str) -> bool:
    cur.execute(
        "SELECT 1 FROM pg_proc p "
        "JOIN pg_namespace n ON n.oid = p.pronamespace "
        "WHERE n.nspname='public' AND p.proname=%s",
        (name,),
    )
    return cur.fetchone() is not None


def has_trigger(cur, table: str, trigger: str) -> bool:
    cur.execute(
        "SELECT 1 FROM pg_trigger tr "
        "JOIN pg_class c ON c.oid = tr.tgrelid "
        "JOIN pg_namespace n ON n.oid = c.relnamespace "
        "WHERE n.nspname='public' AND c.relname=%s AND tr.tgname=%s",
        (table, trigger),
    )
    return cur.fetchone() is not None


def rls_enabled(cur, table: str) -> bool:
    cur.execute(
        "SELECT relrowsecurity FROM pg_class c "
        "JOIN pg_namespace n ON n.oid = c.relnamespace "
        "WHERE n.nspname='public' AND c.relname=%s",
        (table,),
    )
    row = cur.fetchone()
    return row is not None and row[0] is True


def main() -> int:
    url = os.environ.get("SUPABASE_DB_URL")
    if not url:
        print("ERROR: SUPABASE_DB_URL not set.")
        return 2

    info("Connecting to database…")
    conn = psycopg2.connect(url)
    cur = conn.cursor()
    info("Connected. Running checks…")
    print()

    c = Checker(conn)

    # ── v40: sa_audit_log ─────────────────────────────────────────────
    c.run("v40: sa_audit_log table exists", lambda: has_table(cur, "sa_audit_log"))
    c.run("v40: sa_audit_log.actor_id column", lambda: has_column(cur, "sa_audit_log", "actor_id"))
    c.run("v40: sa_audit_log.target_type column", lambda: has_column(cur, "sa_audit_log", "target_type"))
    c.run("v40: sa_audit_log.before JSONB column", lambda: has_column(cur, "sa_audit_log", "before"))
    c.run("v40: RLS enabled on sa_audit_log", lambda: rls_enabled(cur, "sa_audit_log"))

    # ── v39: daily_summaries count column ─────────────────────────────
    c.run("v39: daily_summaries.total_refunds_count", lambda: has_column(cur, "daily_summaries", "total_refunds_count"))

    # ── v38: ZATCA check constraint ───────────────────────────────────
    c.run("v38: invoices ZATCA issued-complete check",
          lambda: has_constraint(cur, "invoices", "invoices_zatca_complete_when_issued"))

    # ── v41: enum constraints ─────────────────────────────────────────
    v41_checks = [
        ("orders", "orders_status_valid"),
        ("sales", "sales_status_valid"),
        ("sales", "sales_payment_method_valid"),
        ("invoices", "invoices_status_valid"),
        ("shifts", "shifts_status_valid"),
        ("purchases", "purchases_status_valid"),
        ("stock_transfers", "stock_transfers_status_valid"),
        ("returns", "returns_status_valid"),
    ]
    for tbl, cnstr in v41_checks:
        c.run(f"v41: {tbl}.{cnstr}", lambda t=tbl, cn=cnstr: has_constraint(cur, t, cn))

    # ── v42: sync_version column + trigger ────────────────────────────
    c.run("v42: sync_version_bump() function exists", lambda: has_function(cur, "sync_version_bump"))
    v42_tables = [
        "sales", "sale_items", "returns", "return_items",
        "shifts", "cash_movements", "invoices", "customers",
        "stock_transfers", "inventory_movements",
    ]
    for t in v42_tables:
        c.run(f"v42: {t}.sync_version column", lambda tbl=t: has_column(cur, tbl, "sync_version"))
        c.run(f"v42: trg_{t}_sync_version trigger", lambda tbl=t: has_trigger(cur, tbl, f"trg_{tbl}_sync_version"))

    cur.close()
    conn.close()

    return c.summary()


if __name__ == "__main__":
    sys.exit(main())
