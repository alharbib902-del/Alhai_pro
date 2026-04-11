import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/org_products_table.dart';

part 'org_products_dao.g.dart';

/// DAO for org_products (centralized organization product catalog)
@DriftAccessor(tables: [OrgProductsTable])
class OrgProductsDao extends DatabaseAccessor<AppDatabase>
    with _$OrgProductsDaoMixin {
  OrgProductsDao(super.db);

  /// Get all active products for an organization
  Future<List<OrgProductsTableData>> getByOrgId(String orgId) {
    return (select(orgProductsTable)
          ..where((p) => p.orgId.equals(orgId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Get a single org product by ID
  Future<OrgProductsTableData?> getById(String id) {
    return (select(
      orgProductsTable,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Get org product by SKU
  Future<OrgProductsTableData?> getBySku(String orgId, String sku) {
    return (select(orgProductsTable)
          ..where((p) => p.orgId.equals(orgId) & p.sku.equals(sku)))
        .getSingleOrNull();
  }

  /// Get org product by barcode
  Future<OrgProductsTableData?> getByBarcode(String orgId, String barcode) {
    return (select(orgProductsTable)
          ..where((p) => p.orgId.equals(orgId) & p.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  /// Search org products by name
  Future<List<OrgProductsTableData>> search(String orgId, String query) {
    final pattern = '%$query%';
    return (select(orgProductsTable)
          ..where(
            (p) =>
                p.orgId.equals(orgId) &
                p.isActive.equals(true) &
                (p.name.like(pattern) |
                    p.nameEn.like(pattern) |
                    p.barcode.like(pattern) |
                    p.sku.like(pattern)),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)])
          ..limit(50))
        .get();
  }

  /// Get products by category
  Future<List<OrgProductsTableData>> getByCategory(
    String orgId,
    String categoryId,
  ) {
    return (select(orgProductsTable)
          ..where(
            (p) =>
                p.orgId.equals(orgId) &
                p.categoryId.equals(categoryId) &
                p.isActive.equals(true),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Get online-available products
  Future<List<OrgProductsTableData>> getOnlineProducts(String orgId) {
    return (select(orgProductsTable)
          ..where(
            (p) =>
                p.orgId.equals(orgId) &
                p.isActive.equals(true) &
                p.onlineAvailable.equals(true),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Insert or update (UPSERT)
  Future<int> upsertOrgProduct(OrgProductsTableCompanion product) =>
      into(orgProductsTable).insertOnConflictUpdate(product);

  /// Batch upsert
  Future<void> batchUpsert(List<OrgProductsTableCompanion> products) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(orgProductsTable, products);
    });
  }

  /// Update an org product (full replace)
  Future<bool> updateOrgProductData(OrgProductsTableData product) =>
      update(orgProductsTable).replace(product);

  /// Update org product images
  Future<int> updateOrgProduct(
    String id, {
    String? orgImageThumbnail,
    String? orgImageMedium,
    String? orgImageLarge,
    String? orgImageHash,
  }) {
    return (update(orgProductsTable)..where((p) => p.id.equals(id))).write(
      OrgProductsTableCompanion(
        orgImageThumbnail: orgImageThumbnail != null
            ? Value(orgImageThumbnail)
            : const Value.absent(),
        orgImageMedium: orgImageMedium != null
            ? Value(orgImageMedium)
            : const Value.absent(),
        orgImageLarge: orgImageLarge != null
            ? Value(orgImageLarge)
            : const Value.absent(),
        orgImageHash: orgImageHash != null
            ? Value(orgImageHash)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft delete
  Future<int> softDelete(String id) {
    return (update(orgProductsTable)..where((p) => p.id.equals(id))).write(
      OrgProductsTableCompanion(
        isActive: const Value(false),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete
  Future<int> deleteOrgProduct(String id) =>
      (delete(orgProductsTable)..where((p) => p.id.equals(id))).go();

  /// Mark as synced
  Future<int> markAsSynced(String id) {
    return (update(orgProductsTable)..where((p) => p.id.equals(id))).write(
      OrgProductsTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// Get count for an organization
  Future<int> getCount(String orgId) async {
    final count = orgProductsTable.id.count();
    final query = selectOnly(orgProductsTable)
      ..addColumns([count])
      ..where(
        orgProductsTable.orgId.equals(orgId) &
            orgProductsTable.isActive.equals(true),
      );
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Watch all active products for an organization
  Stream<List<OrgProductsTableData>> watchByOrgId(String orgId) {
    return (select(orgProductsTable)
          ..where((p) => p.orgId.equals(orgId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }
}
