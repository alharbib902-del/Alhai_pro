# Supabase Migrations Index

All database migrations for the Alhai POS system, listed in chronological order.

## Prerequisites

- `supabase_init.sql` must run first (creates all base tables, functions, RLS policies)
- Migrations are idempotent where possible (safe to re-run)

## Migration History

| Date       | File                                    | Description                                                      |
|------------|-----------------------------------------|------------------------------------------------------------------|
| 2026-01-15 | `20260115_add_r2_images.sql`            | Add Cloudflare R2 multi-size image columns to products table     |
| 2026-01-19 | `20260119_secure_public_products.sql`   | Remove public read RLS policy; secure products via Edge Function |
| 2026-02-23 | `20260223_tighten_rls_write_policies.sql` | Restrict INSERT/UPDATE/DELETE on sensitive tables to admin/manager only |
| 2026-03-05 | `20260305_v14_org_products_online_orders.sql` | Org-scoped products and online orders |
| 2026-03-05 | `20260305_v15_invoices.sql` | Invoice table and realtime |
| 2026-03-05 | `20260305_v16_rpc_functions.sql` | RPC functions for sync |
| 2026-03-06 | `20260306_v17_customers_sales_tables.sql` | Customers and sales tables |
| 2026-03-06 | `20260306_v18_sales_payment_breakdown.sql` | Sales payment breakdown columns |
| 2026-04-01 | `20260401_v19_delivery_system.sql` | Delivery system tables |
| 2026-04-01 | `20260401_v20_store_online_columns.sql` | Store online-ordering columns |
| 2026-04-03 | `20260403_v21_quantity_columns_to_double.sql` | Convert quantity columns to DOUBLE PRECISION |
| 2026-04-03 | `20260403_v22_security_otp_rate_limit_and_permissions.sql` | OTP rate-limiting and security permissions |
| 2026-04-04 | `20260404_v23_nearby_stores_rpc.sql` | RPC for nearby stores |
| 2026-04-04 | `20260404_v24_add_shift_id_to_sales.sql` | Add shift_id column to sales |
| 2026-04-04 | `20260404_v25_create_missing_tables.sql` | Create returns, return_items, cash_movements, audit_log, daily_summaries |
| 2026-04-04 | `20260404_v26_fix_rls_policies.sql` | Replace blanket RLS with store-scoped policies |
| 2026-04-04 | `20260404_v27_create_remaining_tables.sql` | Create inventory_movements, accounts, transactions, held_invoices, favorites, whatsapp_messages |
| 2026-04-04 | `20260404_v28_create_missing_rpcs.sql` | Create check_cashier_by_phone, get_my_stores, get_store_categories, get_store_products RPCs + delivery webhook trigger |
| 2026-04-25 | `20260425_v81_wave9_admin_writes_pii_rpc.sql` | Wave 9 (P0-02 + P0-28): admin-only writes for transactions.adjustment + inventory_movements.{adjust,wastage,stock_take} + get_user_pii RPC |

## Naming Convention

Migrations follow the format: `YYYYMMDD_short_description.sql`

## How to Add a New Migration

1. Create a new `.sql` file following the naming convention
2. Include a header comment with: migration name, date, description, and prerequisites
3. Use `IF NOT EXISTS` / `DROP IF EXISTS` to make migrations idempotent
4. Update this INDEX.md with the new migration entry
5. Test locally with `supabase db reset` before deploying

## Notes

- Cashiers have READ access to most tables but WRITE is restricted to admin/manager
- The `is_store_member()` function checks basic membership; `is_store_admin()` checks admin/manager role
- Product images: `image_url` is deprecated; use `image_thumbnail`, `image_medium`, `image_large`
