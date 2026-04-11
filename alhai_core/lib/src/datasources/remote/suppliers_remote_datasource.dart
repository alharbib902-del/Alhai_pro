import '../../config/app_limits.dart';
import '../../dto/suppliers/supplier_response.dart';
import '../../dto/suppliers/create_supplier_request.dart';
import '../../dto/suppliers/update_supplier_request.dart';

/// Remote data source contract for suppliers API calls
abstract class SuppliersRemoteDataSource {
  /// Gets suppliers for a store
  Future<List<SupplierResponse>> getSuppliers(
    String storeId, {
    bool? activeOnly,
    int page = 1,
    int limit = AppLimits.defaultPageSize,
  });

  /// Gets a supplier by ID
  Future<SupplierResponse> getSupplier(String id);

  /// Creates a new supplier
  Future<SupplierResponse> createSupplier(CreateSupplierRequest request);

  /// Updates an existing supplier
  Future<SupplierResponse> updateSupplier(
    String id,
    UpdateSupplierRequest request,
  );

  /// Deletes a supplier
  Future<void> deleteSupplier(String id);

  /// Gets suppliers with outstanding balance
  Future<List<SupplierResponse>> getSuppliersWithBalance(String storeId);
}
