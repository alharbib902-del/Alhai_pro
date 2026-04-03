# Database Documentation / توثيق قاعدة البيانات

The Alhai platform uses a dual-database architecture: a local Drift (SQLite) database for offline operation and Supabase (PostgreSQL) as the cloud source of truth.

---

## 1. Architecture Overview / نظرة عامة

| Layer          | Technology                  | Purpose                              |
|----------------|-----------------------------|--------------------------------------|
| **Local**      | Drift 2.14 (SQLite / WASM)  | Offline storage, instant reads/writes|
| **Remote**     | Supabase (PostgreSQL 15)    | Cloud sync, multi-device, RLS        |
| **Encryption** | SQLCipher                   | AES-256 encryption on local DB       |
| **Search**     | FTS5                        | Full-text search on products         |

```
+--------------------+           +--------------------+
|  Drift (Local)     |  <-sync-> |  Supabase (Cloud)  |
|  41 tables         |           |  24+ tables        |
|  SQLite / WASM     |           |  PostgreSQL + RLS  |
|  SQLCipher encrypt |           |  Realtime + RPC    |
+--------------------+           +--------------------+
```

### File Locations

| Component        | Path                                            |
|------------------|-------------------------------------------------|
| Table definitions| `packages/alhai_database/lib/src/tables/`        |
| DAOs             | `packages/alhai_database/lib/src/daos/`          |
| FTS5 search      | `packages/alhai_database/lib/src/fts/`           |
| Seeders          | `packages/alhai_database/lib/src/seeders/`       |
| DB connection    | `packages/alhai_database/lib/src/connection*.dart`|
| Base schema      | `supabase/supabase_init.sql`                     |
| Migrations       | `supabase/migrations/`                           |

---

## 2. Tables / الجداول

### 2.1 Core Business Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `organizations`     | Multi-tenant organizations                     | id, name, subscription_plan        |
| `stores`            | Individual store locations                     | id, org_id, name, lat, lng         |
| `users`             | All platform users                             | id, phone, role, is_active         |
| `org_members`       | Organization membership                        | org_id, user_id, role              |
| `store_members`     | Store membership (via base schema)             | store_id, user_id, role_in_store   |

### 2.2 Product & Inventory Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `products`          | Store-level product catalog                    | id, store_id, name, barcode, price, stock_qty |
| `org_products`      | Organization-level master catalog              | id, org_id, default_price, online_available |
| `categories`        | Product categories                             | id, store_id, name, parent_id      |
| `inventory_movements`| Stock adjustments (received, sold, damaged)   | id, product_id, type, qty, reason  |
| `stock_deltas`      | Batch stock changes for sync                   | id, product_id, qty_change         |
| `stock_takes`       | Physical inventory counts                      | id, store_id, status               |
| `stock_transfers`   | Inter-store stock transfers                    | id, from_store, to_store, status   |
| `product_expiry`    | Expiry date tracking per batch                 | id, product_id, expiry_date, qty   |

### 2.3 Sales & Payment Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `sales`             | Completed sales transactions                   | id, store_id, total, payment_method, cash_amount, card_amount, credit_amount |
| `sale_items`        | Line items for each sale                       | id, sale_id, product_id, qty, price|
| `invoices`          | ZATCA-compliant invoices                       | id, store_id, invoice_number, invoice_type, zatca_hash |
| `transactions`      | General financial transactions                 | id, store_id, type, amount         |
| `accounts`          | Customer credit/debt accounts                  | id, customer_id, balance           |
| `held_invoices`     | Paused/held POS invoices                       | id, store_id, items_json           |

### 2.4 Customer & Supplier Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `customers`         | Store customers                                | id, store_id, name, phone, type    |
| `suppliers`         | Product suppliers                              | id, store_id, name, phone          |
| `customer_addresses`| Delivery addresses (v20)                       | id, customer_id, lat, lng, label   |

### 2.5 Order & Delivery Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `orders`            | Online customer orders                         | id, store_id, customer_id, status  |
| `order_items`       | Line items per order (immutable after confirm)  | id, order_id, product_id, qty     |
| `order_status_history`| Status change audit trail                    | id, order_id, old_status, new_status |
| `deliveries`        | Delivery assignments                           | id, order_id, driver_id, status    |
| `driver_locations`  | Real-time driver GPS (one row per driver)      | driver_id, lat, lng, heading, speed|
| `drivers`           | Driver profile and vehicle info                | id, user_id, vehicle_type          |

### 2.6 Purchase Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `purchases`         | Purchase orders from suppliers                 | id, store_id, supplier_id, status  |
| `returns`           | Customer returns and refunds                   | id, sale_id, reason, refund_amount |

### 2.7 Operations Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `shifts`            | Cashier shift open/close                       | id, store_id, user_id, status, opening_cash, closing_cash |
| `expenses`          | Store expense records                          | id, store_id, category, amount     |
| `daily_summaries`   | End-of-day aggregated stats                    | id, store_id, date, total_sales    |
| `audit_log`         | System audit trail                             | id, user_id, action, table_name    |
| `notifications`     | In-app notifications                           | id, user_id, type, message, read   |
| `settings`          | Key-value app settings                         | id, store_id, key, value           |
| `favorites`         | Cashier product favorites/shortcuts            | id, store_id, user_id, product_id  |

### 2.8 Loyalty & Marketing Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `loyalty_points`    | Customer loyalty point balances                | id, customer_id, points            |
| `loyalty_transactions`| Point earn/redeem history                    | id, customer_id, points, type      |
| `loyalty_rewards`   | Available rewards catalog                      | id, store_id, name, points_cost    |
| `discounts`         | Discount rules                                 | id, store_id, type, value          |

### 2.9 Communication Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `whatsapp_messages` | WhatsApp message log                           | id, store_id, phone, message       |
| `whatsapp_templates`| WhatsApp message templates                     | id, store_id, name, body           |

### 2.10 Sync & Infrastructure Tables

| Table               | Purpose                                        | Key Columns                        |
|---------------------|------------------------------------------------|------------------------------------|
| `sync_queue`        | Pending local changes to push to cloud         | id, table_name, record_id, operation, payload |
| `sync_metadata`     | Per-table last-sync timestamps                 | id, table_name, last_synced_at     |
| `pos_terminals`     | Registered POS terminal devices                | id, store_id, device_name          |

---

## 3. Enums / الانواع

Defined in `supabase_init.sql`:

| Enum              | Values                                                              |
|-------------------|---------------------------------------------------------------------|
| `user_role`       | super_admin, store_owner, employee, delivery, customer              |
| `store_role`      | owner, manager, cashier                                             |
| `order_status`    | created, confirmed, preparing, ready, out_for_delivery, delivered, picked_up, completed, cancelled, refunded |
| `delivery_status` | assigned, accepted, heading_to_pickup, arrived_at_pickup, picked_up, heading_to_customer, arrived_at_customer, delivered, cancelled, failed |
| `payment_method`  | cash, card, credit, wallet                                         |
| `adjustment_type` | received, sold, adjustment, damaged, returned                       |
| `debt_type`       | customer_debt, supplier_debt                                        |
| `po_status`       | draft, ordered, partial, received, cancelled                        |
| `promo_type`      | percentage, fixed_amount, buy_x_get_y                               |
| `shift_status`    | open, closed                                                        |

---

## 4. RLS Policies Summary / ملخص سياسات امن الصفوف

Every table has Row Level Security (RLS) enabled. Policies use three helper functions:

```sql
is_super_admin()           -- true if user role = 'super_admin'
is_store_member(store_id)  -- true if user is an active member of the store
is_store_admin(store_id)   -- true if user is owner/manager OR super_admin
```

### Policy Pattern

| Operation | Who Can Do It                              | Example Policy                          |
|-----------|--------------------------------------------|-----------------------------------------|
| SELECT    | Any store member                           | `USING (is_store_member(store_id))`     |
| INSERT    | Admin/Manager only                         | `WITH CHECK (is_store_admin(store_id))` |
| UPDATE    | Admin/Manager only                         | `USING/WITH CHECK (is_store_admin(...))`|
| DELETE    | Admin/Manager only (soft delete preferred) | `USING (is_store_admin(store_id))`      |

### Special RLS Rules

- **`users`**: Users can read/update their own row. Super admin can read all.
- **`role_audit_log`**: Only super_admin can SELECT. All direct writes are blocked (REVOKE ALL); inserts happen via the `update_user_role` RPC function.
- **`org_products`**: Read access for org members; write access for org admins.
- **`orders`**: Customers can read their own orders. Store members can read all store orders.
- **`products` (public read removed)**: After migration v2 (20260119), public read was removed. Products are now served via Edge Function for unauthenticated access.

---

## 5. Triggers / المشغلات

| Trigger                        | Table       | Purpose                                      |
|--------------------------------|-------------|----------------------------------------------|
| `prevent_direct_role_update`   | `users`     | Block direct UPDATE on role column; force RPC |
| `auto_update_updated_at`       | Multiple    | Set `updated_at = NOW()` on every UPDATE      |
| `deduct_stock_on_sale`         | `sale_items`| Decrease product stock_qty after sale confirm  |
| `immutable_order_items`        | `order_items`| Prevent changes after order is confirmed      |
| `auto_create_user_on_signup`   | `auth.users`| Create public.users row when auth user signs up|
| `notify_on_low_stock`          | `products`  | Create notification when stock < min_qty       |
| `notify_on_new_order`          | `orders`    | Create notification for store on new order     |

---

## 6. RPC Functions / الدوال المخزنة

| Function                       | Parameters                  | Purpose                                  |
|--------------------------------|-----------------------------|------------------------------------------|
| `update_user_role`             | user_id, new_role, reason   | Change user role with audit log          |
| `apply_stock_deltas`           | store_id, deltas_json       | Atomic batch stock changes               |
| `reserve_online_stock`         | product_id, qty             | Reserve stock for online order           |
| `release_online_stock`         | product_id, qty             | Release reserved stock (order cancelled) |
| `get_store_stats`              | store_id                    | Dashboard statistics (sales, products, etc.) |

---

## 7. Migration History / تاريخ الترحيلات

Base schema: `supabase/supabase_init.sql` (must run first).

| Version | Date       | File                                         | Description                              |
|---------|------------|----------------------------------------------|------------------------------------------|
| --      | 2026-01-15 | `20260115_add_r2_images.sql`                 | Add Cloudflare R2 multi-size image columns to products |
| --      | 2026-01-19 | `20260119_secure_public_products.sql`        | Remove public read RLS; secure products via Edge Function |
| --      | 2026-02-23 | `20260223_tighten_rls_write_policies.sql`    | Restrict INSERT/UPDATE/DELETE to admin/manager only |
| v14     | 2026-03-05 | `20260305_v14_org_products_online_orders.sql`| org_products catalog, online columns, stock transfer, Realtime |
| v15     | 2026-03-05 | `20260305_v15_invoices.sql`                  | ZATCA-compliant invoices table (simplified_tax, standard_tax, credit/debit notes) |
| v16     | 2026-03-05 | `20260305_v16_rpc_functions.sql`             | RPC: apply_stock_deltas, reserve/release_online_stock, get_store_stats |
| v17     | 2026-03-06 | `20260306_v17_customers_sales_tables.sql`    | Create customers, sales, sale_items tables in Supabase |
| v18     | 2026-03-06 | `20260306_v18_sales_payment_breakdown.sql`   | Add cash_amount, card_amount, credit_amount to sales |
| v19     | 2026-04-01 | `20260401_v19_delivery_system.sql`           | Delivery system: driver_locations, delivery statuses, proof columns |
| v20     | 2026-04-01 | `20260401_v20_store_online_columns.sql`      | Store delivery settings, customer_addresses table |

### How to Apply Migrations

```bash
# 1. Run base schema first (from SQL Editor)
supabase/supabase_init.sql

# 2. Run each migration in order
supabase/migrations/20260115_add_r2_images.sql
supabase/migrations/20260119_secure_public_products.sql
supabase/migrations/20260223_tighten_rls_write_policies.sql
# ... continue in chronological order through v20
```

---

## 8. Sync System / نظام المزامنة

The sync engine lives in `packages/alhai_sync/` and bridges the local Drift database with Supabase.

### Components

| File                      | Purpose                                          |
|---------------------------|--------------------------------------------------|
| `sync_engine.dart`        | Main orchestrator: coordinates push and pull      |
| `sync_manager.dart`       | Lifecycle management, periodic sync scheduling    |
| `pull_sync_service.dart`  | Pull new/updated records from Supabase            |
| `sync_api_service.dart`   | Push local changes to Supabase REST/RPC           |
| `conflict_resolver.dart`  | Resolve conflicts (last-write-wins + custom merge)|
| `connectivity_service.dart`| Monitor network state, trigger sync on reconnect |
| `realtime_listener.dart`  | Supabase Realtime subscriptions for instant updates|
| `initial_sync.dart`       | First-time full download of store data            |
| `sync_status_tracker.dart`| Track sync progress and status for UI indicators  |
| `sync_table_validator.dart`| Validate data integrity before/after sync        |
| `image_upload_service.dart`| Upload product images to Cloudflare R2           |
| `org_sync_service.dart`   | Sync organization-level catalog data              |
| `schema_converter.dart`   | Convert between Drift and Supabase column formats |

### Sync Flow

```
1. App starts
   +-> initial_sync (if first time: download all store data)
   +-> realtime_listener (subscribe to orders, deliveries)

2. User makes a change (e.g., creates a sale)
   +-> Write to Drift (local DB)
   +-> Enqueue in sync_queue (table_name, record_id, operation, payload)

3. Sync engine runs (periodic or on-reconnect)
   +-> Read sync_queue entries in order
   +-> For each: POST/PATCH/DELETE to Supabase
   +-> On success: delete from sync_queue
   +-> On conflict: conflict_resolver decides winner

4. Pull sync (periodic)
   +-> For each table: GET records where updated_at > last_synced_at
   +-> Upsert into local Drift DB
   +-> Update sync_metadata with new timestamp
```

### Conflict Resolution

Default strategy is **last-write-wins** based on `updated_at` timestamp. Custom merge logic exists for:
- **Products**: merge stock_qty changes (delta-based, not absolute)
- **Sales**: server always wins (sales are immutable once synced)
- **Settings**: local wins (user preferences)

---

## 9. Local Schema Versions / اصدارات المخطط المحلي

The Drift database has its own schema versioning (separate from Supabase migrations):

| Version | Description                                                    |
|---------|----------------------------------------------------------------|
| v1      | Base tables: products, sales, sale_items, inventory_movements, accounts, sync_queue |
| v2      | Add transactions table                                         |
| v3      | Add orders and order_items tables                              |
| v4      | Add audit_log table                                            |
| v5      | Add categories table                                           |
| v6      | Add loyalty tables: loyalty_points, loyalty_transactions, loyalty_rewards |
| v7      | Add FTS5 for fast product search                               |
| v8      | Add stores, users, customers, suppliers, shifts, returns, expenses, and more |
| v9      | Add WhatsApp tables: whatsapp_messages, whatsapp_templates     |
| v10     | Add multi-tenant tables: organizations, subscriptions, org_members, user_stores, pos_terminals + org_id column |
| v11     | Add sync tables: sync_metadata, stock_deltas                   |
| v12     | Add deleted_at column for soft delete support                  |
| v13     | Unify quantity columns to REAL type (support fractional quantities like 0.5 kg) |

Migration callbacks are defined in `packages/alhai_database/lib/src/app_database.dart`.

---

## 10. Indexes / الفهارس

Key indexes for performance:

| Table         | Index                              | Purpose                    |
|---------------|------------------------------------|----------------------------|
| `products`    | `(store_id, is_active)`            | Active products per store  |
| `products`    | `(barcode)`                        | Barcode lookup             |
| `products`    | `(image_hash)`                     | Image deduplication        |
| `sales`       | `(store_id, created_at DESC)`      | Recent sales per store     |
| `customers`   | `(store_id, phone)`                | Customer lookup by phone   |
| `customers`   | `(store_id, is_active)`            | Active customers per store |
| `orders`      | `(store_id, status)`               | Order queue by status      |
| `org_products`| `(org_id, is_active)`              | Active catalog items       |
| `org_products`| `(sku)`, `(barcode)`               | SKU and barcode lookup     |
| `sync_queue`  | `(created_at)`                     | Process in order           |
