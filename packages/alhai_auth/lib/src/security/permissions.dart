/// Permissions — centralised capability checks keyed by [User] role.
///
/// Wave 9 (P0-02 + P0-28): role-based gates were scattered across screens
/// as inline `user.role == UserRole.X` comparisons. Each spot drifted as
/// the role list grew, and a new screen author had no canonical place to
/// learn "who can do this?". This class collapses every check into named
/// methods so:
///
/// * Adding a new role updates one file (here), not 30 screens.
/// * A reviewer can grep `Permissions.canX` to see every gate of action X.
/// * The check is mockable in tests without faking a whole [User] graph.
///
/// Server-side enforcement still lives in Supabase RLS — these client-side
/// gates are UX shortcuts (don't show buttons the user can't use), not
/// security guarantees. Wave 9's companion SQL migration adds the
/// matching server-side policies for the few capabilities where a
/// well-formed REST call could otherwise bypass the UI.
library;

import 'package:alhai_core/alhai_core.dart' show User, UserRole;

/// Pure-function gate API. All methods are static + null-safe — pass the
/// current user (or null when unauthenticated) and get a bool back.
class Permissions {
  const Permissions._();

  // ---------------------------------------------------------------------------
  // Identity / role buckets — building blocks the named gates compose.
  // ---------------------------------------------------------------------------

  /// True for super admins — full system access, bypasses every other check.
  static bool isSuperAdmin(User? user) => user?.role == UserRole.superAdmin;

  /// True for store owners — full access within their store.
  static bool isStoreOwner(User? user) => user?.role == UserRole.storeOwner;

  /// True for any administrative role (super admin OR store owner).
  /// Most cashier-app gates use this rather than checking each role.
  static bool isAnyAdmin(User? user) =>
      isSuperAdmin(user) || isStoreOwner(user);

  /// True for cashiers / front-of-house staff.
  static bool isEmployee(User? user) => user?.role == UserRole.employee;

  // ---------------------------------------------------------------------------
  // Customer / accounts management
  // ---------------------------------------------------------------------------

  /// View / open the customer ledger (statements, balances, history).
  /// Cashiers can ring up sales but shouldn't browse account history.
  static bool canViewCustomerLedger(User? user) => isAnyAdmin(user);

  /// Record a manual debit/credit adjustment on a customer account.
  /// Highest-impact ledger action — admin only on both client and server.
  static bool canAdjustCustomerAccount(User? user) => isAnyAdmin(user);

  /// View PII fields (email, phone, last login) of OTHER users.
  /// Cashiers see only their own profile; admins see the whole store.
  /// Server-side: column-level GRANT/REVOKE on `public.users.email/phone`
  /// enforces this regardless of how the call is made.
  static bool canViewOtherUserPii(User? user) => isAnyAdmin(user);

  // ---------------------------------------------------------------------------
  // Sales / pricing
  // ---------------------------------------------------------------------------

  /// Edit the sell price of a product on-the-fly during checkout.
  /// Cashier-level price overrides are a recurring shrinkage vector.
  static bool canEditSalePrice(User? user) => isAnyAdmin(user);

  /// Apply a discount above the per-store soft cap (the cap is enforced
  /// elsewhere; this gate decides who can override it). Soft-cap callers
  /// MUST still check the cap value — Permissions only answers "can the
  /// user override?", not "what's the cap?".
  static bool canOverrideDiscountCap(User? user) => isAnyAdmin(user);

  /// Void a completed sale (refund-style cancellation).
  /// Cashiers can return items; voiding the whole sale is admin-only.
  static bool canVoidSale(User? user) => isAnyAdmin(user);

  // ---------------------------------------------------------------------------
  // Inventory
  // ---------------------------------------------------------------------------

  /// Manual stock adjustment (positive or negative) that doesn't tie to a
  /// purchase order or customer return. High-shrinkage action — admin only.
  /// Server-side: inventory_movements RLS gates `type IN ('adjust',
  /// 'wastage', 'stock_take')` to admin role.
  static bool canRecordStockAdjustment(User? user) => isAnyAdmin(user);

  /// Receive stock against a purchase order or supplier delivery.
  /// Cashiers can receive — they're often the only one in the store.
  static bool canReceiveStock(User? user) => user != null;

  /// Conduct a periodic stock take.
  static bool canRunStockTake(User? user) => isAnyAdmin(user);

  /// Transfer stock between stores. Admin-only because cross-store moves
  /// affect two stores' books.
  static bool canTransferStock(User? user) => isAnyAdmin(user);

  // ---------------------------------------------------------------------------
  // Shifts
  // ---------------------------------------------------------------------------

  /// Open a new shift (start-of-day / start-of-staff).
  static bool canOpenShift(User? user) => user != null;

  /// Close the current shift. Cashiers close their own; admins can close
  /// any. The screen still confirms ownership before showing the button.
  static bool canCloseShift(User? user) => user != null;

  /// Force-close a shift owned by another cashier. Admin-only because
  /// it bypasses the normal cash-reconciliation step.
  static bool canForceCloseShift(User? user) => isAnyAdmin(user);

  // ---------------------------------------------------------------------------
  // Settings / users / system
  // ---------------------------------------------------------------------------

  /// Manage user accounts (create, edit role, deactivate).
  static bool canManageUsers(User? user) => isAnyAdmin(user);

  /// Modify store settings (tax, payment methods, receipt template).
  static bool canEditStoreSettings(User? user) => isAnyAdmin(user);

  /// Trigger a manual backup or change auto-backup settings.
  static bool canManageBackups(User? user) => isAnyAdmin(user);
}
