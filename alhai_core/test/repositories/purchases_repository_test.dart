import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/purchases_remote_datasource.dart';
import 'package:alhai_core/src/dto/purchases/purchase_order_response.dart';
import 'package:alhai_core/src/dto/purchases/create_purchase_order_request.dart';
import 'package:alhai_core/src/dto/purchases/receive_items_request.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/models/purchase_order.dart';
import 'package:alhai_core/src/repositories/purchases_repository.dart';
import 'package:alhai_core/src/repositories/impl/purchases_repository_impl.dart';

// Mock class
class MockPurchasesRemoteDataSource extends Mock
    implements PurchasesRemoteDataSource {}

// Fake classes
class FakeCreatePurchaseOrderRequest extends Fake
    implements CreatePurchaseOrderRequest {}

class FakeReceiveItemsRequest extends Fake implements ReceiveItemsRequest {}

void main() {
  late PurchasesRepositoryImpl repository;
  late MockPurchasesRemoteDataSource mockRemote;

  // Test data - using 'name' and 'lineTotal' which match domain model
  final testPurchaseOrderResponse = PurchaseOrderResponse(
    id: 'po-1',
    storeId: 'store-1',
    supplierId: 'sup-1',
    supplierName: 'Test Supplier',
    status: 'draft',
    items: [
      PurchaseOrderItemResponse(
        productId: 'prod-1',
        name: 'Test Product',
        orderedQty: 10,
        receivedQty: 0,
        unitCost: 50.0,
        lineTotal: 500.0,
      ),
    ],
    subtotal: 500.0,
    discount: 0.0,
    tax: 75.0,
    total: 575.0,
    paidAmount: 0.0,
    createdAt: '2026-01-19T10:00:00Z',
  );

  setUpAll(() {
    registerFallbackValue(FakeCreatePurchaseOrderRequest());
    registerFallbackValue(FakeReceiveItemsRequest());
  });

  setUp(() {
    mockRemote = MockPurchasesRemoteDataSource();
    repository = PurchasesRepositoryImpl(remote: mockRemote);
  });

  group('PurchasesRepositoryImpl', () {
    group('getPurchaseOrders', () {
      test('returns Paginated<PurchaseOrder> on success', () async {
        // Arrange
        when(() => mockRemote.getPurchaseOrders(
              any(),
              status: any(named: 'status'),
              supplierId: any(named: 'supplierId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [testPurchaseOrderResponse]);

        // Act
        final result =
            await repository.getPurchaseOrders('store-1', page: 1, limit: 20);

        // Assert
        expect(result.items, hasLength(1));
        expect(result.items.first.id, equals('po-1'));
        expect(result.items.first.status, equals(PurchaseOrderStatus.draft));
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.getPurchaseOrders(
              any(),
              status: any(named: 'status'),
              supplierId: any(named: 'supplierId'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/purchases'),
        ));

        // Act & Assert
        expect(
          () => repository.getPurchaseOrders('store-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('createPurchaseOrder', () {
      test('creates purchase order successfully', () async {
        // Arrange
        final params = CreatePurchaseOrderParams(
          storeId: 'store-1',
          supplierId: 'sup-1',
          items: [
            PurchaseOrderItem(
              productId: 'prod-1',
              name: 'Test Product',
              orderedQty: 10,
              receivedQty: 0,
              unitCost: 50.0,
              lineTotal: 500.0,
            ),
          ],
        );

        when(() => mockRemote.createPurchaseOrder(any()))
            .thenAnswer((_) async => testPurchaseOrderResponse);

        // Act
        final result = await repository.createPurchaseOrder(params);

        // Assert
        expect(result.id, equals('po-1'));
        expect(result.total, equals(575.0));
        verify(() => mockRemote.createPurchaseOrder(any())).called(1);
      });
    });

    group('receiveItems', () {
      test('receives items successfully', () async {
        // Arrange
        final items = [ReceivedItem(productId: 'prod-1', quantity: 10)];

        when(() => mockRemote.receiveItems(any(), any()))
            .thenAnswer((_) async => testPurchaseOrderResponse);

        // Act
        final result = await repository.receiveItems('po-1', items);

        // Assert
        expect(result.id, equals('po-1'));
        verify(() => mockRemote.receiveItems('po-1', any())).called(1);
      });
    });

    group('cancelPurchaseOrder', () {
      test('cancels purchase order successfully', () async {
        // Arrange
        when(() => mockRemote.cancelPurchaseOrder(any(),
            reason: any(named: 'reason'))).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          repository.cancelPurchaseOrder('po-1', reason: 'Test reason'),
          completes,
        );
      });
    });
  });
}
