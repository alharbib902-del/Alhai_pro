import 'package:drift/native.dart';
import 'package:alhai_database/alhai_database.dart';

/// Create an in-memory database for testing
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Seed the minimal set of top-level parent records that FK constraints require.
///
/// Only seeds records with NO foreign-key parents of their own:
///   stores, users, organizations, suppliers.
///
/// Call this in setUp() after creating the database.  Tests that operate on
/// child tables (products, sales, accounts, etc.) must create their own
/// intermediate parent rows.
Future<void> seedTestData(AppDatabase db) async {
  final now = DateTime(2025, 1, 1);

  // ── Stores (top-level, referenced by most tables) ──
  for (final id in ['store-1', 'store-2', 'test-store']) {
    await db.storesDao.insertStore(
      StoresTableCompanion.insert(
          id: id, name: 'Test Store $id', createdAt: now),
    );
  }

  // ── Users / cashiers (top-level, referenced by sales.cashierId etc.) ──
  for (final id in ['user-1', 'user-2', 'cashier-1', 'cashier-2']) {
    await db.into(db.usersTable).insert(
          UsersTableCompanion.insert(
              id: id, name: 'Test User $id', createdAt: now),
        );
  }

  // ── Suppliers (top-level, referenced by accounts, purchases) ──
  for (final id in ['sup-1', 'sup-2']) {
    await db.suppliersDao.insertSupplier(
      SuppliersTableCompanion.insert(
        id: id,
        storeId: 'store-1',
        name: 'Test Supplier $id',
        createdAt: now,
      ),
    );
  }

  // ── Organizations (top-level, referenced by org_products, org_members) ──
  for (final id in ['org-1', 'org-2']) {
    await db.organizationsDao.insertOrganization(
      OrganizationsTableCompanion.insert(
        id: id,
        name: 'Test Org $id',
        createdAt: now,
      ),
    );
  }
}
