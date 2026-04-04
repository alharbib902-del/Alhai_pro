/// Centralised Permission Constants for the Admin App
///
/// Single source of truth for all permission string identifiers used across
/// the admin dashboard — router guards, roles screen, and sync payloads.
///
/// The router guards in `admin_router.dart` use [_permissionsForRole] to
/// derive a permission set from the user's [UserRole]. When a full RBAC
/// system is wired (permissions stored per-user in the DB), replace that
/// helper with a live permission-set lookup.
library;

/// Permission string constants for the Admin app.
///
/// Usage:
/// ```dart
/// if (user.hasPermission(AdminPermissions.usersManage)) { ... }
/// ```
abstract class AdminPermissions {
  AdminPermissions._();

  // ── User & Role Management ──────────────────────────────────────
  /// Create, edit, disable, or delete users.
  static const String usersManage = 'users_manage';

  /// View the user list (read-only).
  static const String usersView = 'users_view';

  /// Create, edit, or delete roles and their permission sets.
  static const String rolesManage = 'roles_manage';

  // ── Settings ────────────────────────────────────────────────────
  /// Access and modify store, POS, receipt, and other settings.
  static const String settingsManage = 'settings_manage';

  /// View settings (read-only).
  static const String settingsView = 'settings_view';

  // ── Reports & Analytics ─────────────────────────────────────────
  /// View reports, dashboards, and analytics.
  static const String reportsView = 'reports_view';

  /// Export reports to CSV/PDF.
  static const String reportsExport = 'reports_export';

  // ── Products & Inventory ────────────────────────────────────────
  /// Create, edit, or delete products.
  static const String productsManage = 'products_manage';

  /// View product catalogue (read-only).
  static const String productsView = 'products_view';

  /// Delete products from the system.
  static const String productsDelete = 'products_delete';

  /// View inventory counts (read-only).
  static const String inventoryView = 'inventory_view';

  /// Manage inventory counts, adjustments, and transfers.
  static const String inventoryManage = 'inventory_manage';

  /// Manually adjust inventory quantities.
  static const String inventoryAdjust = 'inventory_adjust';

  // ── Purchases & Suppliers ───────────────────────────────────────
  /// Create and manage purchase orders and supplier returns.
  static const String purchasesManage = 'purchases_manage';

  /// View purchase history (read-only).
  static const String purchasesView = 'purchases_view';

  // ── Marketing ───────────────────────────────────────────────────
  /// Create and manage discounts, coupons, and promotions.
  static const String marketingManage = 'marketing_manage';

  /// Apply existing discounts at POS.
  static const String discountsApply = 'discounts_apply';

  /// Create new discount rules.
  static const String discountsCreate = 'discounts_create';

  // ── Customers ───────────────────────────────────────────────────
  /// Create, edit, or delete customer records.
  static const String customersManage = 'customers_manage';

  /// View customer list and details (read-only).
  static const String customersView = 'customers_view';

  /// Delete customers from the system.
  static const String customersDelete = 'customers_delete';

  // ── Financial ───────────────────────────────────────────────────
  /// Manage expenses, invoices, and financial records.
  static const String financialManage = 'financial_manage';

  /// Request a refund for products.
  static const String refundsRequest = 'refunds_request';

  /// Approve refund requests.
  static const String refundsApprove = 'refunds_approve';

  // ── POS Operations ──────────────────────────────────────────────
  /// Access the POS / sales screens.
  static const String posAccess = 'pos_access';

  /// Hold invoices and resume later.
  static const String posHold = 'pos_hold';

  /// Split payment across multiple methods.
  static const String posSplitPayment = 'pos_split_payment';

  /// Open and close cash drawers / shifts.
  static const String shiftsManage = 'shifts_manage';

  // ── Staff ───────────────────────────────────────────────────────
  /// View employee list (read-only).
  static const String staffView = 'staff_view';

  /// Add, edit, or manage employees.
  static const String staffManage = 'staff_manage';

  // ── System ──────────────────────────────────────────────────────
  /// View activity / audit logs.
  static const String auditLogView = 'audit_log_view';

  /// Manage backup and restore operations.
  static const String backupManage = 'backup_manage';

  /// Manage device and sync settings.
  static const String devicesManage = 'devices_manage';

  // ── Convenience lists ───────────────────────────────────────────

  /// All available permission identifiers (useful for seeding roles).
  static const List<String> all = [
    usersManage,
    usersView,
    rolesManage,
    settingsManage,
    settingsView,
    reportsView,
    reportsExport,
    productsManage,
    productsView,
    productsDelete,
    inventoryView,
    inventoryManage,
    inventoryAdjust,
    purchasesManage,
    purchasesView,
    marketingManage,
    discountsApply,
    discountsCreate,
    customersManage,
    customersView,
    customersDelete,
    financialManage,
    refundsRequest,
    refundsApprove,
    posAccess,
    posHold,
    posSplitPayment,
    shiftsManage,
    staffView,
    staffManage,
    auditLogView,
    backupManage,
    devicesManage,
  ];

  /// Permissions granted to a default "owner" role.
  static const List<String> ownerDefaults = all;

  /// Permissions granted to a default "manager" role.
  static const List<String> managerDefaults = [
    usersView,
    settingsView,
    reportsView,
    reportsExport,
    productsManage,
    productsView,
    productsDelete,
    inventoryView,
    inventoryManage,
    inventoryAdjust,
    purchasesManage,
    purchasesView,
    marketingManage,
    discountsApply,
    discountsCreate,
    customersManage,
    customersView,
    financialManage,
    refundsRequest,
    refundsApprove,
    posAccess,
    posHold,
    posSplitPayment,
    shiftsManage,
    staffView,
    staffManage,
    auditLogView,
  ];

  /// Permissions granted to a default "cashier" role.
  static const List<String> cashierDefaults = [
    productsView,
    customersView,
    posAccess,
    posHold,
    shiftsManage,
    discountsApply,
  ];
}
