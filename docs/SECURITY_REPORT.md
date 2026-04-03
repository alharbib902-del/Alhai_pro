# Alhai Platform - Security Report

**Version:** 1.0.0
**Date:** 2026-04-03
**Scope:** Supabase backend, RLS policies, authentication, data protection
**Status:** Active

---

## Table of Contents

1. [RLS Coverage Matrix](#1-rls-coverage-matrix)
2. [Authentication Security](#2-authentication-security)
3. [Session Management](#3-session-management)
4. [Data Protection Measures](#4-data-protection-measures)
5. [OWASP Top 10 Assessment](#5-owasp-top-10-assessment)
6. [Identified Gaps and Recommendations](#6-identified-gaps-and-recommendations)
7. [Dependency Audit Recommendations](#7-dependency-audit-recommendations)

---

## 1. RLS Coverage Matrix

### 1.1 Core Tables (supabase_init.sql)

| Table | RLS Enabled | SELECT Policy | INSERT Policy | UPDATE Policy | DELETE Policy | Notes |
|---|---|---|---|---|---|---|
| `users` | Yes | `users_self_select`, `users_superadmin_select` | `users_customer_upsert_own` (v20) | `users_self_update`, `users_superadmin_update` | None | No DELETE policy - users persist |
| `role_audit_log` | Yes | `role_audit_superadmin_read` | None (REVOKE ALL) | None (REVOKE ALL) | None (REVOKE ALL) | Fully locked, super_admin read only |
| `stores` | Yes | `stores_public_read_active`, `stores_staff_read_own`, `stores_member_select`, `stores_superadmin_all` | `stores_owner_insert` | `stores_owner_update` | `stores_owner_delete` | Multiple SELECT paths; authenticated required |
| `store_members` | Yes | `store_members_self_read`, `store_members_staff_read`, `store_members_superadmin_all` | `store_members_admin_insert` | `store_members_admin_update` | `store_members_admin_delete` | Self-read + admin management |
| `categories` | Yes | `categories_public_read_active`, `categories_staff_read_all`, `categories_superadmin_all` | `categories_staff_insert` (admin) | `categories_staff_update` (admin) | `categories_staff_delete` (admin) | Public can read active categories |
| `products` | Yes | `products_staff_read_all`, `products_superadmin_all` | `products_staff_insert` (admin) | `products_staff_update` (admin) | `products_staff_delete` (admin) | Public read removed in v119 migration |
| `addresses` | Yes | `addresses_user_all` | `addresses_customer_insert` (v20) | `addresses_customer_update` (v20) | `addresses_customer_delete` (v20) | User owns their own addresses |
| `orders` | Yes | `orders_customer_read`, `orders_customer_read_own` (v20), `orders_staff_read`, `orders_superadmin_all` | `orders_customer_insert`, `orders_customer_create` (v20) | `orders_customer_update_created`, `orders_staff_update` | None for customer DELETE | Customers can only update orders in 'created' status |
| `order_items` | Yes | `order_items_read_via_order`, `order_items_superadmin_all` | `order_items_customer_insert`, `order_items_staff_insert` | `order_items_staff_update_created` | `order_items_staff_delete_created` | Scoped through parent order |
| `suppliers` | Yes | `suppliers_staff_read`, `suppliers_superadmin_all` | `suppliers_staff_insert` (admin) | `suppliers_staff_update` (admin) | `suppliers_staff_delete` (admin) | Admin-only writes |
| `debts` | Yes | `debts_staff_read`, `debts_superadmin_all` | `debts_staff_insert` (admin) | `debts_staff_update` (admin) | `debts_staff_delete` (admin) | Admin-only writes |
| `debt_payments` | Yes | `debt_payments_staff_read`, `debt_payments_superadmin_all` | `debt_payments_staff_insert` (admin) | None (REVOKE) | None (REVOKE) | INSERT through admin, UPDATE/DELETE revoked |
| `deliveries` | Yes | `deliveries_driver_read`, `deliveries_staff_read`, `deliveries_superadmin_all` | `deliveries_staff_insert` | `deliveries_driver_update`, `deliveries_staff_update` | None | Driver can read/update own; staff scoped via order |
| `customer_accounts` | Yes | `customer_accounts_customer_read`, `customer_accounts_staff_read`, `customer_accounts_superadmin_all` | None | None | None | Read-only for customers and staff |
| `loyalty_points` | Yes | `loyalty_points_customer_read`, `loyalty_points_staff_read`, `loyalty_points_superadmin_all` | None | None | None | Read-only access |
| `stock_adjustments` | Yes | `stock_adj_staff_read`, `stock_adj_superadmin_select` | `stock_adj_staff_insert` (admin), `stock_adj_superadmin_insert` | None (REVOKE) | None (REVOKE) | Append-only audit trail |
| `purchase_orders` | Yes | `purchase_orders_staff_read`, `purchase_orders_superadmin_all` | `purchase_orders_staff_insert` (admin) | `purchase_orders_staff_update` (admin) | `purchase_orders_staff_delete` (admin) | Admin-only writes |
| `purchase_order_items` | Yes | `po_items_staff_read`, `po_items_superadmin_all` | `po_items_staff_insert` (admin) | `po_items_staff_update` (admin) | `po_items_staff_delete` (admin) | Scoped through parent PO |
| `notifications` | Yes | `notifications_user_read`, `notifications_superadmin_all` | None | `notifications_user_update` | None | Users read/mark-read own notifications |
| `promotions` | Yes | `promotions_public_read_active`, `promotions_staff_read`, `promotions_superadmin_all` | `promotions_staff_insert` (admin) | `promotions_staff_update` (admin) | `promotions_staff_delete` (admin) | Public can see active promos |
| `order_payments` | Yes | `order_payments_read_via_order`, `order_payments_superadmin_all` | `order_payments_staff_insert` | None (REVOKE) | None (REVOKE) | Append-only |
| `store_settings` | Yes | `store_settings_staff_read`, `store_settings_superadmin_all` | `store_settings_admin_insert` | `store_settings_admin_update` | None | Admin-only writes |
| `activity_logs` | Yes | `activity_logs_staff_read` (admin), `activity_logs_superadmin_all` | `activity_logs_staff_insert` | None (REVOKE) | None (REVOKE) | Append-only audit trail |
| `shifts` | Yes | `shifts_cashier_read_own`, `shifts_staff_read`, `shifts_admin_all`, `shifts_superadmin_all` | `shifts_staff_insert` | `shifts_cashier_update_own_open` | None | Cashier can only update own open shift |

### 1.2 Migration-Added Tables

| Table | RLS Enabled | Policy Type | Notes |
|---|---|---|---|
| `org_products` (v14) | Yes | Org-member read, org-admin write | Proper org_members-based isolation |
| `invoices` (v15) | Yes | Org-member read/write via org_members | All active org members can insert/update |
| `customers` (v17) | Yes | **"Allow authenticated full access"** | **GAP: overly permissive** |
| `sales` (v17) | Yes | **"Allow authenticated full access"** | **GAP: overly permissive** |
| `sale_items` (v17) | Yes | **"Allow authenticated full access"** | **GAP: overly permissive** |
| `driver_locations` (v19) | Yes | Driver own + admin + customer active delivery | Fine-grained |
| `driver_shifts` (v19) | Yes | Driver own + admin | Proper isolation |
| `chat_messages` (v19) | Yes | Participant-based (driver/customer/admin) | Well-designed |
| `delivery_proofs` (v19) | Yes | Driver insert, participant read | Good |

### 1.3 Compatibility Migration Tables (fix_compatibility.sql)

These 23 tables were created with **"Allow authenticated full access"** policies (USING true / WITH CHECK true):

| Table | RLS Enabled | Policy | Risk Level |
|---|---|---|---|
| `organizations` | Yes | Allow authenticated full access | **HIGH** |
| `subscriptions` | Yes | Allow authenticated full access | **HIGH** |
| `org_members` | Yes | Allow authenticated full access | **HIGH** |
| `user_stores` | Yes | Allow authenticated full access | **HIGH** |
| `roles` | Yes | Allow authenticated full access | **MEDIUM** |
| `discounts` | Yes | Allow authenticated full access | **MEDIUM** |
| `coupons` | Yes | Allow authenticated full access | **MEDIUM** |
| `expenses` | Yes | Allow authenticated full access | **MEDIUM** |
| `expense_categories` | Yes | Allow authenticated full access | **LOW** |
| `purchases` | Yes | Allow authenticated full access | **MEDIUM** |
| `purchase_items` | Yes | Allow authenticated full access | **MEDIUM** |
| `drivers` | Yes | Allow authenticated full access | **MEDIUM** |
| `loyalty_transactions` | Yes | Allow authenticated full access | **MEDIUM** |
| `loyalty_rewards` | Yes | Allow authenticated full access | **LOW** |
| `customer_addresses` | Yes | Allow authenticated full access | **MEDIUM** |
| `order_status_history` | Yes | Allow authenticated full access | **LOW** |
| `pos_terminals` | Yes | Allow authenticated full access | **MEDIUM** |
| `product_expiry` | Yes | Allow authenticated full access | **LOW** |
| `stock_takes` | Yes | Allow authenticated full access | **MEDIUM** |
| `stock_transfers` | Yes | Allow authenticated full access | **MEDIUM** |
| `stock_deltas` | Yes | Allow authenticated full access | **MEDIUM** |
| `whatsapp_templates` | Yes | Allow authenticated full access | **LOW** |
| `settings` | Yes | Allow authenticated full access | **MEDIUM** |

### 1.4 Compatibility Migration Overridden Tables

These tables had their original RLS policies dropped and replaced with "Allow authenticated full access" during the compatibility migration:

| Table | Original Policies | Current Policy | Risk |
|---|---|---|---|
| `orders` | Proper customer/staff isolation | **Allow authenticated full access** | **CRITICAL** |
| `order_items` | Proper via-order scoping | **Allow authenticated full access** | **CRITICAL** |
| `shifts` | Cashier own + admin | **Allow authenticated full access** | **HIGH** |
| `loyalty_points` | Customer + staff read | **Allow authenticated full access** | **HIGH** |
| `notifications` | User own | **Allow authenticated full access** | **HIGH** |
| `suppliers` | Staff read, admin write | **Allow authenticated full access** | **HIGH** |
| `promotions` | Public active + admin write | **Allow authenticated full access** | **MEDIUM** |

### 1.5 Storage Buckets

| Bucket | Public | Upload Restriction | Read Restriction |
|---|---|---|---|
| `product-images` | Yes | Store member (via user_stores) | Public |
| `store-logos` | Yes | Owner/admin only | Public |
| `receipts` | No | Store member | Store member |
| `backups` | No | Owner/admin | Owner/admin |
| `invoice-attachments` | No | Store member | Store member |
| `delivery-proofs` | No | Delivery role users | Authenticated |

---

## 2. Authentication Security

### 2.1 Authentication Flow

- **Provider:** Supabase Auth (phone OTP + email)
- **New user trigger:** `handle_new_user()` on `auth.users` INSERT creates a `public.users` record with default role `customer`
- **Role management:** Only via `update_user_role()` RPC, restricted to `super_admin`
- **Direct role update blocked:** `prevent_direct_role_update` trigger on `public.users` prevents UPDATE on role column unless `app.role_update` flag is set

### 2.2 Strengths

- Role changes are audited in `role_audit_log`
- `update_user_role()` validates caller is super_admin before proceeding
- Super_admin roles cannot be changed by other super_admins (privilege escalation protection)
- SECURITY DEFINER functions pin `search_path` to prevent search path injection

### 2.3 Concerns

- **No rate limiting** on auth endpoints at the database level (relies on Supabase built-in limits)
- **No MFA enforcement** in the schema (relies on Supabase Auth config)
- **PIN field** on `users` table is stored as plaintext TEXT (added in fix_compatibility.sql)

---

## 3. Session Management

### 3.1 Current Implementation

- **Session management:** Delegated entirely to Supabase Auth (JWT tokens)
- **Token refresh:** Handled by Supabase client SDK
- **Shift-based sessions:** POS shifts (`shifts` table) track cashier sessions with opening/closing cash reconciliation

### 3.2 Protections

- `shifts_cashier_update_own_open`: Cashiers can only update their own open shift (not others')
- Unique index `idx_shifts_cashier_open` prevents multiple open shifts per cashier
- `store_id` change prevention trigger on store_members prevents lateral movement

### 3.3 Recommendations

- Consider adding `last_activity_at` column to shifts for idle timeout detection
- Add session invalidation on role change (currently role change does not revoke active JWTs)

---

## 4. Data Protection Measures

### 4.1 Implemented Protections

| Measure | Status | Details |
|---|---|---|
| RLS on all tables | Partial | 24 core tables have proper RLS; 26 tables have permissive policies |
| Immutable audit trails | Yes | `stock_adjustments`, `activity_logs`, `order_payments` have UPDATE/DELETE revoked |
| store_id immutability | Yes | Trigger prevents changing store_id on products, store_members, debts, purchase_orders |
| Role change audit | Yes | `role_audit_log` tracks all role changes with old/new values and changed_by |
| SECURITY DEFINER + search_path | Yes | All helper functions use SECURITY DEFINER with pinned search_path |
| Stock deduction validation | Yes | Trigger checks sufficient stock before deducting on order confirmation |
| Delivery state machine | Yes | `update_delivery_status()` validates transitions against allowed state graph |
| File size limits | Yes | Storage buckets have file_size_limit (1MB to 50MB) |
| MIME type restrictions | Yes | Storage buckets restrict allowed_mime_types |

### 4.2 Encryption

- **At rest:** Supabase manages disk encryption (provider responsibility)
- **In transit:** HTTPS/TLS enforced by Supabase edge
- **Application-level encryption:** Not implemented for sensitive fields (PINs, tax numbers)

### 4.3 PII Handling

| Field | Table | Protection |
|---|---|---|
| Phone | users, customers, stores | RLS scoped to self or store members |
| Email | users, stores | RLS scoped to self or store members |
| Tax number | stores, customers | RLS scoped, but stores_public_read_active exposes it |
| PIN | users | **Stored as plaintext** |
| FCM token | users | RLS scoped to self |
| Customer VAT | invoices | RLS scoped to org members |

---

## 5. OWASP Top 10 Assessment

### A01:2021 - Broken Access Control

**Risk: MEDIUM-HIGH**

- **Positive:** Core tables (products, categories, suppliers, debts, POs) have proper is_store_admin / is_store_member policies
- **Negative:** 26+ tables have "Allow authenticated full access" policies. Any authenticated user (including customers) can read/write data belonging to any store in these tables
- **Negative:** The fix_compatibility.sql migration dropped proper RLS from orders, order_items, shifts, loyalty_points, notifications, suppliers, promotions and replaced them with permissive policies
- **Impact:** A customer could read all store sales data, modify another store's expenses, or tamper with stock deltas

### A02:2021 - Cryptographic Failures

**Risk: MEDIUM**

- PINs are stored as plaintext in the users table
- No application-level encryption for sensitive business data
- ZATCA fields (hash, QR, UUID) are stored as-is without additional encryption
- Tax numbers exposed through stores_public_read_active policy

### A03:2021 - Injection

**Risk: LOW**

- Supabase uses parameterized queries by default
- RPC functions use proper parameterized SQL (no string concatenation in queries)
- `search_path` is pinned on all SECURITY DEFINER functions
- Input validation present in RPC functions (null checks, limit clamping)

### A04:2021 - Insecure Design

**Risk: MEDIUM**

- The delivery confirmation code system has max 3 attempts (good)
- Stock reservation with FOR UPDATE locking prevents race conditions (good)
- However, the compatibility migration created a design debt by replacing secure policies with permissive ones

### A05:2021 - Security Misconfiguration

**Risk: MEDIUM**

- RLS is enabled on all tables (good)
- REVOKE statements properly restrict immutable tables (good)
- However, 26 tables effectively have RLS disabled through USING(true) policies
- Function ownership properly set (update_user_role owned by postgres)

### A06:2021 - Vulnerable and Outdated Components

**Risk: UNKNOWN**

- No automated dependency scanning observed
- Flutter/Dart dependencies not audited at the database level
- Supabase version not pinned in the schema

### A07:2021 - Identification and Authentication Failures

**Risk: LOW-MEDIUM**

- Authentication delegated to Supabase Auth (industry standard)
- Phone OTP provides second factor
- No account lockout at the database level (relies on Supabase config)
- No password policy enforcement visible in schema (OTP-based, so less relevant)

### A08:2021 - Software and Data Integrity Failures

**Risk: LOW**

- Audit trails are append-only (UPDATE/DELETE revoked)
- Role changes require RPC with audit logging
- store_id immutability triggers prevent data reassignment
- Stock adjustments create audit records before modifying quantities

### A09:2021 - Security Logging and Monitoring Failures

**Risk: MEDIUM**

- `activity_logs` table exists for store-level actions
- `role_audit_log` tracks role changes
- `order_status_history` tracks order state changes
- No centralized security event logging (failed auth attempts, RLS violations)
- No alerting on suspicious activity patterns

### A10:2021 - Server-Side Request Forgery (SSRF)

**Risk: LOW**

- No user-controlled URLs used in server-side fetching at the database level
- Edge Functions (product images) would need separate SSRF review

---

## 6. Identified Gaps and Recommendations

### 6.1 Critical: Replace Permissive Policies

**Priority: P0**

The following tables need proper store-scoped RLS policies to replace "Allow authenticated full access":

**Immediate (financial/sensitive data):**
- `sales` - should use `is_store_member(store_id)` for read, `is_store_admin(store_id)` for write
- `sale_items` - scope through parent `sales.store_id`
- `orders` - restore original customer/staff policies
- `order_items` - restore original via-order scoping
- `expenses` - scope to store members
- `purchases` - scope to store members
- `purchase_items` - scope through parent purchase
- `organizations` - scope to org_members
- `subscriptions` - scope to org owner/admin
- `shifts` - restore cashier own + admin policies

**High priority:**
- `org_members` - scope to org members
- `user_stores` - scope to self read, admin write
- `customers` - scope to store members (contains PII)
- `customer_addresses` - scope to customer self
- `loyalty_points` - restore customer read + staff read
- `loyalty_transactions` - scope to store members
- `notifications` - restore user own
- `suppliers` - restore staff read, admin write
- `promotions` - restore public active + admin write
- `stock_deltas` - scope to store members
- `stock_transfers` - scope to from/to store members
- `stock_takes` - scope to store members

**Medium priority:**
- `discounts`, `coupons` - scope to store members
- `drivers` - scope to store members
- `pos_terminals` - scope to store members
- `roles` - scope to store admin
- `settings` - scope to store members
- `whatsapp_templates` - scope to store members

**Lower priority:**
- `expense_categories`, `loyalty_rewards`, `product_expiry`, `order_status_history`

### 6.2 High: Encrypt PINs

**Priority: P1**

The `users.pin` column stores employee PINs as plaintext. These should be hashed using `pgcrypto`:

```sql
-- Store hashed PINs
UPDATE users SET pin = crypt(pin, gen_salt('bf')) WHERE pin IS NOT NULL;

-- Verify PINs
SELECT id FROM users WHERE pin = crypt('1234', pin);
```

### 6.3 High: Restrict Sensitive Fields on Public Store Read

**Priority: P1**

The `stores_public_read_active` policy exposes all store columns to any authenticated user, including `tax_number`, `commercial_reg`, `phone`, `email`. Consider either:
- Creating a view that exposes only public fields
- Using column-level security

### 6.4 Medium: Add RLS to invoices DELETE

**Priority: P2**

The `invoices` table (v15) has SELECT, INSERT, UPDATE policies but no DELETE policy. For ZATCA compliance, invoices should likely be non-deletable:

```sql
-- Explicitly prevent deletion
CREATE POLICY "invoices_no_delete" ON public.invoices
  FOR DELETE USING (false);
```

### 6.5 Medium: RPC Authorization Gaps

**Priority: P2**

Several SECURITY DEFINER functions lack internal authorization checks:
- `apply_stock_deltas()` - No check that caller is a member of the store
- `reserve_online_stock()` - No check that caller is a member of the store
- `release_reserved_stock()` - No authorization check at all
- `sync_org_product_to_stores()` - No authorization check

These should add store membership verification like the `get_store_categories()` and `get_store_products()` functions do.

### 6.6 Low: Add Row-Level Audit Columns

**Priority: P3**

Consider adding `created_by` and `updated_by` columns to tables that lack them, populated via triggers using `auth.uid()`.

---

## 7. Dependency Audit Recommendations

### 7.1 Flutter/Dart Dependencies

Run the following regularly:

```bash
# In each app directory
flutter pub outdated
flutter pub audit  # Available in Dart 3.x
```

Key packages to monitor:
- `supabase_flutter` - Authentication and data access
- `drift` - Local database (SQL injection surface if raw queries used)
- `go_router` - Route security
- `crypto` / `encrypt` - Any encryption utilities

### 7.2 Supabase Platform

- Monitor Supabase release notes for security patches
- Review Edge Function dependencies separately
- Ensure PostgREST version is current (Supabase managed)

### 7.3 Recommended Tooling

| Tool | Purpose | Frequency |
|---|---|---|
| `flutter pub audit` | Dart package vulnerability scan | Every release |
| `npm audit` (E2E tests) | Node.js test dependency scan | Every release |
| Supabase Dashboard > Database > Advisors | PostgreSQL security advisors | Monthly |
| OWASP ZAP | Dynamic application security testing | Quarterly |
| Snyk / Dependabot | Automated dependency monitoring | Continuous |

### 7.4 CI/CD Integration

Recommended pipeline additions:

1. **Pre-merge:** Run `flutter pub audit` and fail on high/critical CVEs
2. **Pre-deploy:** Run RLS test suite (`supabase/tests/rls_test.sql`) against staging
3. **Post-deploy:** Verify RLS is enabled on all tables via information_schema query
4. **Weekly:** Automated dependency update PRs via Dependabot or Renovate

---

## Appendix: File References

| File | Purpose |
|---|---|
| `supabase/supabase_init.sql` | Core schema, RLS policies, helper functions, triggers |
| `supabase/supabase_owner_only.sql` | Owner-privileged operations (trigger on auth.users) |
| `supabase/storage_policies.sql` | Storage bucket creation and RLS policies |
| `supabase/sync_rpc_functions.sql` | Data sync RPC functions with authorization |
| `supabase/fix_rls_recursion.sql` | Fix for infinite recursion in stores RLS |
| `supabase/fix_stores_rls.sql` | Fix store member SELECT policy |
| `supabase/fix_compatibility.sql` | Drift/Supabase compatibility - created permissive policies |
| `supabase/fix_auth.sql` | Auth cleanup and handle_new_user restoration |
| `supabase/migrations/20260119_secure_public_products.sql` | Remove public product read, fix is_store_member |
| `supabase/migrations/20260223_tighten_rls_write_policies.sql` | Restrict writes to admin on 4 tables |
| `supabase/migrations/20260305_v14_org_products_online_orders.sql` | Org products with proper org-based RLS |
| `supabase/migrations/20260305_v15_invoices.sql` | Invoices with org-member RLS |
| `supabase/migrations/20260306_v17_customers_sales_tables.sql` | Customers/sales with permissive policies |
| `supabase/migrations/20260401_v19_delivery_system.sql` | Delivery system with granular RLS |
| `supabase/migrations/20260401_v20_store_online_columns.sql` | Customer app policies (addresses, orders) |
| `supabase/tests/rls_test.sql` | RLS test suite |
| `supabase/rls_policies.sql` | Combined RLS policy reference |
