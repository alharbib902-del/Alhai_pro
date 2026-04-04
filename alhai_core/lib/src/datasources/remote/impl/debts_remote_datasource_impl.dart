import 'package:dio/dio.dart';

import '../../../dto/debts/create_debt_request.dart';
import '../../../dto/debts/debt_payment_response.dart';
import '../../../dto/debts/debt_response.dart';
import '../../../dto/debts/debt_summary_response.dart';
import '../debts_remote_datasource.dart';

/// Implementation of DebtsRemoteDataSource
class DebtsRemoteDataSourceImpl implements DebtsRemoteDataSource {
  final Dio _dio;

  DebtsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<DebtResponse>> getDebts(
    String storeId, {
    String? type,
    bool? overdueOnly,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/debts',
      queryParameters: {
        'store_id': storeId,
        if (type != null) 'type': type,
        if (overdueOnly != null) 'overdue_only': overdueOnly,
        'page': page,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => DebtResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DebtResponse> getDebt(String id) async {
    final response = await _dio.get('/debts/$id');
    return DebtResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DebtResponse>> getPartyDebts(String partyId) async {
    final response = await _dio.get(
      '/debts/party/$partyId',
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => DebtResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DebtResponse> createDebt(CreateDebtRequest request) async {
    final response = await _dio.post(
      '/debts',
      data: request.toJson(),
    );
    return DebtResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DebtPaymentResponse> recordPayment(
      RecordPaymentRequest request) async {
    final response = await _dio.post(
      '/debts/${request.debtId}/payments',
      data: request.toJson(),
    );
    return DebtPaymentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DebtPaymentResponse>> getPayments(String debtId) async {
    final response = await _dio.get('/debts/$debtId/payments');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => DebtPaymentResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DebtSummaryResponse> getDebtSummary(String storeId) async {
    final response = await _dio.get(
      '/debts/summary',
      queryParameters: {'store_id': storeId},
    );
    return DebtSummaryResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
