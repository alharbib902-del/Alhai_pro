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
