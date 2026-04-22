import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

/// Exception thrown when a supplier rating is outside the valid 0-5 range.
class InvalidSupplierRatingException implements Exception {
  final int rating;
  const InvalidSupplierRatingException(this.rating);

  @override
  String toString() =>
      'InvalidSupplierRatingException: rating $rating is outside the valid range 0-5';
}

/// DAO for suppliers
@DriftAccessor(tables: [SuppliersTable])
class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  /// Valid rating range: 0 (unrated) to 5 (excellent).
  static const int minRating = 0;
  static const int maxRating = 5;

  /// Validates that [rating] is within the allowed 0-5 range.
  /// Throws [InvalidSupplierRatingException] if out of range.
  static void validateRating(int rating) {
    if (rating < minRating || rating > maxRating) {
      throw InvalidSupplierRatingException(rating);
    }
  }

  /// Clamps a rating value to the valid 0-5 range instead of throwing.
  static int clampRating(int rating) => rating.clamp(minRating, maxRating);

  Future<List<SuppliersTableData>> getAllSuppliers(String storeId) {
    return (select(suppliersTable)
          ..where((s) => s.storeId.equals(storeId) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.name)])
          ..limit(500))
        .get();
  }

  Future<List<SuppliersTableData>> getActiveSuppliers(String storeId) {
    return (select(suppliersTable)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.isActive.equals(true) &
              s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.name)])
          ..limit(500))
        .get();
  }

  Future<SuppliersTableData?> getSupplierById(String id) =>
      (select(suppliersTable)
            ..where((s) => s.id.equals(id) & s.deletedAt.isNull()))
          .getSingleOrNull();

  Future<List<SuppliersTableData>> searchSuppliers(
    String query,
    String storeId,
  ) {
    return (select(suppliersTable)
          ..where(
            (s) =>
                s.storeId.equals(storeId) &
                s.deletedAt.isNull() &
                (s.name.contains(query) | s.phone.contains(query)),
          )
          ..limit(20))
        .get();
  }

  /// Inserts a supplier after validating the rating is within 0-5.
  /// Throws [InvalidSupplierRatingException] if rating is out of range.
  Future<int> insertSupplier(SuppliersTableCompanion supplier) {
    if (supplier.rating case final Value<int> v when v.present) {
      validateRating(v.value);
    }
    return into(suppliersTable).insert(supplier);
  }

  /// Updates a supplier after validating the rating is within 0-5.
  /// Throws [InvalidSupplierRatingException] if rating is out of range.
  Future<bool> updateSupplier(SuppliersTableData supplier) {
    validateRating(supplier.rating);
    return update(suppliersTable).replace(supplier);
  }

  /// [newBalance] is SAR (double); stored as int cents internally.
  Future<int> updateBalance(String id, double newBalance) {
    return (update(suppliersTable)..where((s) => s.id.equals(id))).write(
      SuppliersTableCompanion(
        balance: Value((newBalance * 100).round()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Updates the supplier rating (0-5).
  /// Throws [InvalidSupplierRatingException] if [newRating] is out of range.
  Future<int> updateRating(String id, int newRating) {
    validateRating(newRating);
    return (update(suppliersTable)..where((s) => s.id.equals(id))).write(
      SuppliersTableCompanion(
        rating: Value(newRating),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteSupplier(String id) =>
      (delete(suppliersTable)..where((s) => s.id.equals(id))).go();

  Future<int> markAsSynced(String id) {
    return (update(suppliersTable)..where((s) => s.id.equals(id))).write(
      SuppliersTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  Stream<List<SuppliersTableData>> watchSuppliers(String storeId) {
    return (select(suppliersTable)
          ..where((s) => s.storeId.equals(storeId) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }
}
