# Database Technical Debt Notes

## F3: Barcode UNIQUE constraint missing

**Source:** Phase 4 independent verification (2026-04-15)
**Severity:** HIGH
**Status:** DEFERRED to next sprint
**Discovered by:** Claude (independent verifier session)

### Problem

`packages/alhai_database/lib/src/tables/products_table.dart` line 48:
`barcode` column is defined as `text().nullable()()` without any
`unique()` modifier.

The UI check in `apps/admin/lib/screens/products/product_form_screen.dart`
(C3 fix from Phase 4) only validates at the form level. The following
paths bypass the check:

1. **Sync from Supabase:** `SyncService` imports products without
   barcode validation
2. **Race conditions:** Two devices simultaneously adding the same
   barcode both pass the UI check
3. **Future bulk import:** Any bulk import feature would bypass
4. **Direct DAO access:** Any code that calls `productsDao.insert()`
   directly bypasses

### Fix Plan

1. Create migration `XX_add_barcode_unique_constraint.sql`:
```sql
   -- Allow NULL but ensure non-null barcodes are unique per store
   CREATE UNIQUE INDEX idx_products_store_barcode_unique
     ON products(store_id, barcode)
     WHERE barcode IS NOT NULL;
```

2. Handle existing duplicates BEFORE applying migration:
   - Query: `SELECT store_id, barcode, COUNT(*) FROM products
            WHERE barcode IS NOT NULL GROUP BY store_id, barcode
            HAVING COUNT(*) > 1`
   - For each duplicate: append suffix to all but oldest
     (e.g., `123456` → `123456-DUP-2`)

3. Update `getProductByBarcode()` to handle errors gracefully
   (currently uses `getSingleOrNull()` which throws on >1 result)

4. Add integration test:
   - Insert product with barcode "ABC123"
   - Try insert another product with "ABC123" in same store
   - Expect `SqliteException(constraint_unique)`
   - Verify Supabase sync conflict resolution

### Estimated Effort

2-3 hours (migration + duplicate handling + tests)

### Target

Before Phase 5 OR during next schema cleanup sprint

### Risk if Not Fixed

- Inventory accuracy degraded
- Sales associated with wrong products
- ZATCA invoice line items reference ambiguous SKUs
- Customer complaints about wrong items in receipts
