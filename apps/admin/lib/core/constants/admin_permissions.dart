/// Centralised Permission Constants for the Admin App
///
/// Provides a single source of truth for all permission string identifiers
/// used across the admin dashboard. Currently the router guards check
/// [UserRole] directly; when a full RBAC system is wired these constants
/// should be matched against the authenticated user's permission set
/// (e.g. stored in `role_permissions` table).
///
/// See also: `admin_router.dart` – `_guardRedirect` uses role-level checks
/// that should eventually be replaced with these granular permissions.
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

  /// Manage inventory counts, adjustments, and transfers.
  static const String inventoryManage = 'inventory_manage';

  // ── Purchases & Suppliers ───────────────────────────────────────
  /// Create and manage purchase orders and supplier returns.
  static const String purchasesManage = 'purchases_manage';

  /// View purchase history (read-only).
  static const String purchasesView = 'purchases_view';

  // ── Marketing ───────────────────────────────────────────────────
  /// Create and manage discounts, coupons, and promotions.
  static const String marketingManage = 'marketing_manage';

  // ── Customers ───────────────────────────────────────────────────
  /// Create, edit, or delete customer records.
  static const String customersManage = 'customers_manage';

  /// View customer list and details (read-only).
  static const String customersView = 'customers_view';

  // ── Financial ───────────────────────────────────────────────────
  /// Manage expenses, invoices, and financial records.
  static const String financialManage = 'financial_manage';

  /// Process refunds and returns.
  static const String refundsManage = 'refunds_manage';

  // ── POS Operations ──────────────────────────────────────────────
  /// Access the POS / sales screens.
  static const String posAccess = 'pos_access';

  /// Open and close cash drawers / shifts.
  static const String shiftsManage = 'shifts_manage';

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
    inventoryManage,
    purchasesManage,
    purchasesView,
    marketingManage,
    customersManage,
    customersView,
    financialManage,
    refundsManage,
    posAccess,
    shiftsManage,
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
    inventoryManage,
    purchasesManage,
    purchasesView,
    marketingManage,
    customersManage,
    customersView,
    financialManage,
    refundsManage,
    posAccess,
    shiftsManage,
    auditLogView,
  ];

  /// Permissions granted to a default "cashier" role.
  static const List<String> cashierDefaults = [
    productsView,
    customersView,
    posAccess,
    shiftsManage,
  ];
}
