import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/orders_remote_datasource.dart';
import 'package:alhai_core/src/dto/orders/order_response.dart';
import 'package:alhai_core/src/dto/orders/order_item_response.dart';
import 'package:alhai_core/src/dto/orders/create_order_request.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/models/create_order_params.dart';
import 'package:alhai_core/src/models/order_item.dart';
import 'package:alhai_core/src/models/enums/order_status.dart';
import 'package:alhai_core/src/models/enums/payment_method.dart';
import 'package:alhai_core/src/repositories/impl/orders_repository_impl.dart';

// Mock class
class MockOrdersRemoteDataSource extends Mock implements OrdersRemoteDataSource {}

// Fake classes
class FakeCreateOrderRequest extends Fake implements CreateOrderRequest {}

void main() {
  late OrdersRepositoryImpl repository;
  late MockOrdersRemoteDataSource mockRemote;

  // Test data
  final testOrderItemResponse = OrderItemResponse(
    productId: 'prod-1',
    name: 'Test Product',
    unitPrice: 50.0,
    qty: 2,
    lineTotal: 100.0,
  );

  final testOrderResponse = OrderResponse(
    id: 'order-1',
    storeId: 'store-1',
    customerId: 'cust-1',
    customerName: 'Test Customer',
    customerPhone: '+966500000000',
    status: 'created',
    items: [testOrderItemResponse],
    subtotal: 100.0,
    discount: 10.0,
    tax: 15.0,
    total: 105.0,
    paymentMethod: 'cash',
    notes: 'Test order',
    createdAt: '2026-01-10T10:00:00Z',
    updatedAt: '2026-01-11T10:00:00Z',
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateOrderRequest());
  });

  setUp(() {
    mockRemote = MockOrdersRemoteDataSource();
    repository = OrdersRepositoryImpl(remote: mockRemote);
  });

  group('OrdersRepositoryImpl', () {
    group('createOrder', () {
      test('creates order with correct DTO mapping', () async {
        // Arrange
        final params = CreateOrderParams(
          clientOrderId: 'client-order-1',
          storeId: 'store-1',
          items: [
            OrderItem(
              productId: 'prod-1',
              name: 'Test Product',
              unitPrice: 50.0,
              qty: 2,
              lineTotal: 100.0,
            ),
          ],
          paymentMethod: PaymentMethod.cash,
        );

        when(() => mockRemote.createOrder(any()))
            .thenAnswer((_) async => testOrderResponse);

        // Act
        final result = await repository.createOrder(params);

        // Assert
        expect(result.id, equals('order-1'));
        expect(result.status, equals(OrderStatus.created));
        expect(result.items, hasLength(1));
        verify(() => mockRemote.createOrder(any())).called(1);
      });

      test('throws ValidationException on invalid data', () async {
        // Arrange
        final params = CreateOrderParams(
          clientOrderId: 'client-order-2',
          storeId: 'store-1',
          items: [],
          paymentMethod: PaymentMethod.cash,
        );

        when(() => mockRemote.createOrder(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'message': 'Items cannot be empty'},
            requestOptions: RequestOptions(path: '/orders'),
          ),
          requestOptions: RequestOptions(path: '/orders'),
        ));

        // Act & Assert
        expect(
          () => repository.createOrder(params),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('getOrder', () {
      test('returns Order on success', () async {
        // Arrange
        when(() => mockRemote.getOrder(any()))
            .thenAnswer((_) async => testOrderResponse);

        // Act
        final result = await repository.getOrder('order-1');

        // Assert
        expect(result.id, equals('order-1'));
        expect(result.customerName, equals('Test Customer'));
        expect(result.total, equals(105.0));
        verify(() => mockRemote.getOrder('order-1')).called(1);
      });
    });

    group('getOrders', () {
      test('returns paginated orders with status filter', () async {
        // Arrange
        when(() => mockRemote.getOrders(
              status: any(named: 'status'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [testOrderResponse]);

        // Act
        final result = await repository.getOrders(
          status: OrderStatus.created,
          page: 1,
          limit: 10,
        );

        // Assert
        expect(result.items, hasLength(1));
        expect(result.items.first.status, equals(OrderStatus.created));
        verify(() => mockRemote.getOrders(
              status: 'created',
              page: 1,
              limit: 10,
            )).called(1);
      });

      test('returns all orders when status is null', () async {
        // Arrange
        when(() => mockRemote.getOrders(
              status: any(named: 'status'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [testOrderResponse]);

        // Act
        final result = await repository.getOrders();

        // Assert
        expect(result.items, hasLength(1));
        verify(() => mockRemote.getOrders(
              status: null,
              page: 1,
              limit: 20,
            )).called(1);
      });
    });

    group('updateStatus', () {
      test('updates order status successfully', () async {
        // Arrange
        when(() => mockRemote.updateStatus(any(), any()))
            .thenAnswer((_) async => testOrderResponse);

        // Act
        final result = await repository.updateStatus('order-1', OrderStatus.confirmed);

        // Assert
        expect(result.id, equals('order-1'));
        verify(() => mockRemote.updateStatus('order-1', 'confirmed')).called(1);
      });
    });

    group('cancelOrder', () {
      test('cancels order with reason', () async {
        // Arrange
        when(() => mockRemote.cancelOrder(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          repository.cancelOrder('order-1', reason: 'Customer request'),
          completes,
        );
        verify(() => mockRemote.cancelOrder('order-1', reason: 'Customer request'))
            .called(1);
      });

      test('cancels order without reason', () async {
        // Arrange
        when(() => mockRemote.cancelOrder(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.cancelOrder('order-1'), completes);
        verify(() => mockRemote.cancelOrder('order-1', reason: null)).called(1);
      });
    });
  });
}
