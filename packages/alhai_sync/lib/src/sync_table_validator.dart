/// Whitelist of allowed table names for sync SQL operations.
///
/// Prevents SQL injection by validating tableName before use in raw SQL.
const Set<String> allowedSyncTables = {
  'stores',
  'users',
  'categories',
  'products',
  'customers',
  'suppliers',
  'sales',
  'sale_items',
  'orders',
  'order_items',
  'purchases',
  'purchase_items',
  'returns',
  'return_items',
  'accounts',
  'transactions',
  'inventory_movements',
  'expenses',
  'expense_categories',
  'shifts',
  'pos_terminals',
  'notifications',
  'discounts',
  'coupons',
  'promotions',
  'loyalty_points',
  'loyalty_transactions',
  'loyalty_rewards',
  'settings',
  'organizations',
  'org_members',
  'user_stores',
  'favorites',
  'drivers',
  'customer_addresses',
  'product_expiry',
  'whatsapp_templates',
  'whatsapp_messages',
  'roles',
  'daily_summaries',
  'org_products',
  'stock_transfers',
  'stock_deltas',
  'invoices',
};

/// Validates that a table name is in the allowed whitelist.
/// Throws [ArgumentError] if the table name is not allowed.
void validateTableName(String tableName) {
  if (!allowedSyncTables.contains(tableName)) {
    throw ArgumentError('Invalid sync table name: $tableName');
  }
}
