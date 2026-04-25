/// تصدير جميع DAOs
library;

// DAOs الأساسية
export 'products_dao.dart';
export 'sales_dao.dart';
export 'sale_items_dao.dart';
export 'inventory_dao.dart';
export 'accounts_dao.dart';
export 'sync_queue_dao.dart';
export 'transactions_dao.dart';
export 'orders_dao.dart';
export 'audit_log_dao.dart';
export 'categories_dao.dart';
export 'loyalty_dao.dart';

// DAOs الجديدة
export 'stores_dao.dart';
export 'users_dao.dart';
export 'customers_dao.dart';
export 'suppliers_dao.dart';
export 'shifts_dao.dart';
export 'returns_dao.dart';
export 'expenses_dao.dart';
export 'purchases_dao.dart';
export 'discounts_dao.dart';
export 'notifications_dao.dart';

// DAOs واتساب
export 'whatsapp_messages_dao.dart';
export 'whatsapp_templates_dao.dart';

// DAOs متعددة المستأجرين
export 'organizations_dao.dart';
export 'org_members_dao.dart';
export 'pos_terminals_dao.dart';
export 'org_products_dao.dart';

// DAO نقل المخزون
export 'stock_transfers_dao.dart';

// DAO الفواتير
export 'invoice_counter_dao.dart';
export 'invoices_dao.dart';

// DAOs المزامنة
export 'sync_metadata_dao.dart';
export 'stock_deltas_dao.dart';

// DAO طابور ZATCA offline
export 'zatca_offline_queue_dao.dart';
