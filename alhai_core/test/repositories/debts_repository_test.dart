import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/debts_remote_datasource.dart';
import 'package:alhai_core/src/dto/debts/debt_response.dart';
import 'package:alhai_core/src/dto/debts/create_debt_request.dart';
import 'package:alhai_core/src/dto/debts/debt_payment_response.dart';
import 'package:alhai_core/src/dto/debts/debt_summary_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/models/debt.dart';
import 'package:alhai_core/src/repositories/debts_repository.dart';
import 'package:alhai_core/src/repositories/impl/debts_repository_impl.dart';

// Mock class
class MockDebtsRemoteDataSource extends Mock implements DebtsRemoteDataSource {}

// Fake classes
class FakeCreateDebtRequest extends Fake implements CreateDebtRequest {}

class FakeRecordPaymentRequest extends Fake implements RecordPaymentRequest {}

void main() {
  late DebtsRepositoryImpl repository;
  late MockDebtsRemoteDataSource mockRemote;

  // Test data - using 'customer' string for type (converted to DebtType.customerDebt in toDomain)
  const testDebtResponse = DebtResponse(
    id: 'debt-1',
    storeId: 'store-1',
    type: 'customer',
    partyId: 'cust-1',
    partyName: 'Test Customer',
    partyPhone: '0500000000',
    originalAmount: 500.0,
    remainingAmount: 300.0,
    createdAt: '2026-01-19T10:00:00Z',
  );

  const testPaymentResponse = DebtPaymentResponse(
    id: 'pay-1',
    debtId: 'debt-1',
    amount: 100.0,
    paymentMethod: 'cash',
    createdAt: '2026-01-19T10:00:00Z',
  );

  const testSummaryResponse = DebtSummaryResponse(
    totalCustomerDebts: 5000.0,
    totalSupplierDebts: 3000.0,
    overdueCount: 2,
    overdueAmount: 1000.0,
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateDebtRequest());
    registerFallbackValue(FakeRecordPaymentRequest());
  });

  setUp(() {
    mockRemote = MockDebtsRemoteDataSource();
    repository = DebtsRepositoryImpl(remote: mockRemote);
  });

  group('DebtsRepositoryImpl', () {
    group('getDebts', () {
      test('returns Paginated<Debt> on success', () async {
        // Arrange
        when(() => mockRemote.getDebts(
              any(),
              type: any(named: 'type'),
              overdueOnly: any(named: 'overdueOnly'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [testDebtResponse]);

        // Act
        final result = await repository.getDebts('store-1', page: 1, limit: 20);

        // Assert
        expect(result.items, hasLength(1));
        expect(result.items.first.id, equals('debt-1'));
        expect(result.items.first.type, equals(DebtType.customerDebt));
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.getDebts(
              any(),
              type: any(named: 'type'),
              overdueOnly: any(named: 'overdueOnly'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/debts'),
        ));

        // Act & Assert
        expect(
          () => repository.getDebts('store-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('createDebt', () {
      test('creates debt successfully', () async {
        // Arrange
        const params = CreateDebtParams(
          storeId: 'store-1',
          type: DebtType.customerDebt,
          partyId: 'cust-1',
          partyName: 'Test Customer',
          amount: 500.0,
        );

        when(() => mockRemote.createDebt(any()))
            .thenAnswer((_) async => testDebtResponse);

        // Act
        final result = await repository.createDebt(params);

        // Assert
        expect(result.id, equals('debt-1'));
        verify(() => mockRemote.createDebt(any())).called(1);
      });
    });

    group('recordPayment', () {
      test('records payment successfully', () async {
        // Arrange
        const params = RecordPaymentParams(
          debtId: 'debt-1',
          amount: 100.0,
          paymentMethod: 'cash',
        );

        when(() => mockRemote.recordPayment(any()))
            .thenAnswer((_) async => testPaymentResponse);

        // Act
        final result = await repository.recordPayment(params);

        // Assert
        expect(result.id, equals('pay-1'));
        expect(result.amount, equals(100.0));
      });
    });

    group('getDebtSummary', () {
      test('returns DebtSummary on success', () async {
        // Arrange
        when(() => mockRemote.getDebtSummary(any()))
            .thenAnswer((_) async => testSummaryResponse);

        // Act
        final result = await repository.getDebtSummary('store-1');

        // Assert
        expect(result.totalCustomerDebts, equals(5000.0));
        expect(result.netDebt, equals(2000.0));
      });
    });
  });
}
