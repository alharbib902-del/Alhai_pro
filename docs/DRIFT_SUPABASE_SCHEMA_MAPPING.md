# Drift-Supabase Schema Mapping

## Summary
| Metric | Count |
|--------|-------|
| Supabase Tables | 27 |
| Drift Tables | 41 |
| Matching Tables | 18 |
| Drift-only Tables | 23 |
| Supabase-only Tables | 9 |

## Key Type Mismatches

| Issue | Supabase | Drift | Conversion |
|-------|----------|-------|------------|
| Primary Keys | UUID | TEXT | UUID.toString() / parse |
| Quantities | INT | REAL | .toInt() / .toDouble() |
| ENUMs | Custom types | TEXT | Validate against allowed values |
| JSON | JSONB | TEXT | jsonEncode/jsonDecode |
| Decimal | DECIMAL(10,2) | REAL | Round to 2 decimals on sync |

## Type Conversion Layer

```dart
/// Convert Supabase UUID to Drift TEXT ID
String supabaseIdToDrift(String uuid) => uuid; // TEXT stores UUID string

/// Convert Drift REAL qty to Supabase INT
int driftQtyToSupabase(double qty) => qty.round();

/// Convert Supabase ENUM to Drift TEXT
String supabaseEnumToDrift(String enumValue) => enumValue;

/// Convert Supabase JSONB to Drift TEXT
String supabaseJsonToDrift(Map<String, dynamic> json) => jsonEncode(json);

/// Convert Drift TEXT JSON to Supabase JSONB
Map<String, dynamic> driftJsonToSupabase(String text) =>
    jsonDecode(text) as Map<String, dynamic>;
```

## Table Mapping Reference

### Matching Tables (sync both directions)
| Supabase | Drift | Notes |
|----------|-------|-------|
| users | UsersTable | UUID→TEXT, ENUM role→TEXT |
| stores | StoresTable | Well aligned |
| categories | CategoriesTable | Well aligned |
| products | ProductsTable | Well aligned |
| orders | OrdersTable | Drift has extra delivery fields |
| order_items | OrderItemsTable | INT qty→REAL |
| suppliers | SuppliersTable | Drift has extra fields |
| purchase_orders | PurchasesTable | UUID→TEXT |
| purchase_order_items | PurchaseItemsTable | INT qty→REAL |
| stock_adjustments | InventoryMovementsTable | ENUM→TEXT |
| notifications | NotificationsTable | JSONB data→TEXT |
| loyalty_points | LoyaltyTable | Well aligned |
| shifts | ShiftsTable | Drift has more metrics |
| activity_logs | AuditLogTable | JSONB→TEXT, INET→TEXT |
| promotions | PromotionsTable + CouponsTable | Split structure |
| debts | AccountsTable | Different approach to debt tracking |
| customer_accounts | CustomersTable + AccountsTable | Denormalized in Drift |
| store_settings | StoresTable (embedded) | Supabase has separate table |

### Drift-only Tables (local/offline)
SalesTable, SaleItemsTable, AccountsTable, TransactionsTable, StockDeltasTable, DiscountsTable, CouponsTable, ReturnsTable, ReturnItemsTable, ExpensesTable, ExpenseCategoriesTable, DriversTable, OrganizationsTable, OrgMembersTable, UserStoresTable, SyncMetadataTable, SyncQueueTable, WhatsAppMessagesTable, WhatsAppTemplatesTable, SettingsTable, HeldInvoicesTable, FavoritesTable, DailySummariesTable

### Supabase-only Tables (server-side)
role_audit_log, store_members, addresses, debt_payments, deliveries, store_settings, order_payments

## Sync Strategy

### Supabase → Drift (Pull)
1. Convert UUIDs to TEXT (lossless)
2. Store ENUM values as TEXT strings
3. Stringify JSONB to TEXT
4. Convert INT quantities to REAL
5. Map split tables to denormalized Drift tables

### Drift → Supabase (Push)
1. TEXT IDs used as-is (valid UUID strings)
2. Validate TEXT against allowed ENUM values
3. Parse TEXT JSON to JSONB
4. Round REAL quantities to INT
5. Split denormalized data into normalized tables

### Conflict Resolution
- **Last-write-wins** using `updated_at` timestamps
- **Server-authoritative** for user roles, permissions
- **Client-authoritative** for offline sales, returns
- **Merge** for stock quantities using delta sync
