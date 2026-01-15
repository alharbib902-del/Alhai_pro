import '../models/paginated.dart';
import '../models/supplier.dart';

/// Repository contract for supplier operations
abstract class SuppliersRepository {
  /// Gets all suppliers for a store
  Future<Paginated<Supplier>> getSuppliers(
    String storeId, {
    bool? activeOnly,
    int page = 1,
    int limit = 20,
  });

  /// Gets a supplier by ID
  Future<Supplier> getSupplier(String id);

  /// Creates a new supplier
  Future<Supplier> createSupplier(CreateSupplierParams params);

  /// Updates an existing supplier
  Future<Supplier> updateSupplier(String id, UpdateSupplierParams params);

  /// Deletes a supplier
  Future<void> deleteSupplier(String id);

  /// Gets suppliers with outstanding balance
  Future<List<Supplier>> getSuppliersWithBalance(String storeId);
}

/// Parameters for creating a supplier
class CreateSupplierParams {
  final String storeId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  const CreateSupplierParams({
    required this.storeId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });
}

/// Parameters for updating a supplier
class UpdateSupplierParams {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool? isActive;

  const UpdateSupplierParams({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.isActive,
  });
}
