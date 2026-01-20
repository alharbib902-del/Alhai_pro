import 'package:dio/dio.dart';

import '../../datasources/remote/suppliers_remote_datasource.dart';
import '../../dto/suppliers/create_supplier_request.dart';
import '../../dto/suppliers/update_supplier_request.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/paginated.dart';
import '../../models/supplier.dart';
import '../suppliers_repository.dart';

/// Implementation of SuppliersRepository
class SuppliersRepositoryImpl implements SuppliersRepository {
  final SuppliersRemoteDataSource _remote;

  SuppliersRepositoryImpl({
    required SuppliersRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Paginated<Supplier>> getSuppliers(
    String storeId, {
    bool? activeOnly,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getSuppliers(
        storeId,
        activeOnly: activeOnly,
        page: page,
        limit: limit,
      );

      final items = responses.map((r) => r.toDomain()).toList();
      final hasMore = items.length >= limit;

      return Paginated(
        items: items,
        page: page,
        limit: limit,
        hasMore: hasMore,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Supplier> getSupplier(String id) async {
    try {
      final response = await _remote.getSupplier(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Supplier> createSupplier(CreateSupplierParams params) async {
    try {
      final request = CreateSupplierRequest.fromDomain(params);
      final response = await _remote.createSupplier(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Supplier> updateSupplier(String id, UpdateSupplierParams params) async {
    try {
      final request = UpdateSupplierRequest.fromDomain(params);
      final response = await _remote.updateSupplier(id, request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _remote.deleteSupplier(id);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<Supplier>> getSuppliersWithBalance(String storeId) async {
    try {
      final responses = await _remote.getSuppliersWithBalance(storeId);
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
