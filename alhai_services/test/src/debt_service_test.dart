import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeDebtsRepository implements DebtsRepository {
  @override
  Future<Paginated<Debt>> getDebts(String storeId,
          {DebtType? type,
          bool? overdueOnly,
          int page = 1,
          int limit = 20}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Debt> getDebt(String id) async => throw UnimplementedError();
  @override
  Future<List<Debt>> getPartyDebts(String partyId) async => [];
  @override
  Future<Debt> createDebt(CreateDebtParams params) async =>
      throw UnimplementedError();
  @override
  Future<DebtPayment> recordPayment(RecordPaymentParams params) async =>
      throw UnimplementedError();
  @override
  Future<List<DebtPayment>> getPayments(String debtId) async => [];
  @override
  Future<DebtSummary> getDebtSummary(String storeId) async => DebtSummary(
      totalCustomerDebts: 300.0,
      totalSupplierDebts: 700.0,
      overdueCount: 2,
      overdueAmount: 200.0);
}

void main() {
  late DebtService debtService;
  setUp(() {
    debtService = DebtService(FakeDebtsRepository());
  });

  group('DebtService', () {
    test('should be created', () {
      expect(debtService, isNotNull);
    });
    test('getDebts should return paginated result', () async {
      final result = await debtService.getDebts('store-1');
      expect(result.items, isA<List<Debt>>());
    });
    test('getPartyDebts should return list', () async {
      final debts = await debtService.getPartyDebts('party-1');
      expect(debts, isA<List<Debt>>());
    });
    test('getPaymentHistory should return list', () async {
      final payments = await debtService.getPaymentHistory('debt-1');
      expect(payments, isA<List<DebtPayment>>());
    });
    test('getDebtSummary should return summary', () async {
      final summary = await debtService.getDebtSummary('store-1');
      expect(summary.totalCustomerDebts, equals(300.0));
      expect(summary.totalSupplierDebts, equals(700.0));
    });
    test('getTotalCustomerDebts should return total', () async {
      final total = await debtService.getTotalCustomerDebts('store-1');
      expect(total, equals(300.0));
    });
    test('getTotalSupplierDebts should return total', () async {
      final total = await debtService.getTotalSupplierDebts('store-1');
      expect(total, equals(700.0));
    });
    test('getOverdueDebts should return paginated', () async {
      final result = await debtService.getOverdueDebts('store-1');
      expect(result, isA<Paginated<Debt>>());
    });
  });
}
