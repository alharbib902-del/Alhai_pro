/// تصدير جميع جداول Drift
library;

// الجداول الأساسية
export 'products_table.dart';
export 'sales_table.dart';
export 'sale_items_table.dart';
export 'inventory_movements_table.dart';
export 'accounts_table.dart';
export 'sync_queue_table.dart';
export 'transactions_table.dart';
export 'orders_table.dart';
export 'order_items_table.dart';
export 'audit_log_table.dart';
export 'categories_table.dart';
export 'loyalty_table.dart';

// جداول الأولوية العالية
export 'stores_table.dart';
export 'users_table.dart';
export 'customers_table.dart';
export 'suppliers_table.dart';
export 'shifts_table.dart';
export 'returns_table.dart';
export 'expenses_table.dart';

// جداول الأولوية المتوسطة
export 'purchases_table.dart';
export 'discounts_table.dart';
export 'held_invoices_table.dart';
export 'notifications_table.dart';
export 'stock_transfers_table.dart';
export 'settings_table.dart';

// جداول الأولوية المنخفضة
export 'stock_takes_table.dart';
export 'product_expiry_table.dart';
export 'drivers_table.dart';
export 'daily_summaries_table.dart';
export 'order_status_history_table.dart';
export 'favorites_table.dart';

// جداول واتساب
export 'whatsapp_messages_table.dart';
export 'whatsapp_templates_table.dart';

// جداول متعددة المستأجرين
export 'organizations_table.dart';
export 'org_members_table.dart';
export 'pos_terminals_table.dart';
export 'org_products_table.dart';

// الفواتير الرسمية
export 'invoices_table.dart';

// جداول المزامنة
export 'sync_metadata_table.dart';
export 'stock_deltas_table.dart';
