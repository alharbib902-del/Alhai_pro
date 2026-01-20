import 'package:dio/dio.dart';

import '../../datasources/remote/debts_remote_datasource.dart';
import '../../dto/debts/create_debt_request.dart';
import '../../dto/debts/debt_payment_response.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/debt.dart';
import '../../models/paginated.dart';
import '../debts_repository.dart';

/// Implementation of DebtsRepository
class DebtsRepositoryImpl implements DebtsRepository {
  final DebtsRemoteDataSource _remote;

  DebtsRepositoryImpl({
    required DebtsRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Paginated<Debt>> getDebts(
    String storeId, {
    DebtType? type,
    bool? overdueOnly,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getDebts(
        storeId,
        type: type?.name,
        overdueOnly: overdueOnly,
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
  Future<Debt> getDebt(String id) async {
    try {
      final response = await _remote.getDebt(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<Debt>> getPartyDebts(String partyId) async {
    try {
      final responses = await _remote.getPartyDebts(partyId);
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Debt> createDebt(CreateDebtParams params) async {
    try {
      final request = CreateDebtRequest.fromDomain(params);
      final response = await _remote.createDebt(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<DebtPayment> recordPayment(RecordPaymentParams params) async {
    try {
      final request = RecordPaymentRequest.fromDomain(params);
      final response = await _remote.recordPayment(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<DebtPayment>> getPayments(String debtId) async {
    try {
      final responses = await _remote.getPayments(debtId);
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<DebtSummary> getDebtSummary(String storeId) async {
    try {
      final response = await _remote.getDebtSummary(storeId);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
