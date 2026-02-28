import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/transfers_repository.dart';

/// Tests for Transfer, TransferItem, TransferStatus, TransferDirection
/// defined in transfers_repository.dart.
/// TransfersRepository is an abstract interface - no implementation to test yet.
void main() {
  group('Transfer Model', () {
    test('should construct with all required fields', () {
      final transfer = Transfer(
        id: 'transfer-1',
        sourceStoreId: 'store-1',
        destinationStoreId: 'store-2',
        sourceStoreName: 'Store A',
        destinationStoreName: 'Store B',
        items: const [
          TransferItem(
            productId: 'p1',
            productName: 'Product 1',
            quantity: 10,
          ),
        ],
        status: TransferStatus.pending,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(transfer.id, equals('transfer-1'));
      expect(transfer.sourceStoreId, equals('store-1'));
      expect(transfer.destinationStoreId, equals('store-2'));
      expect(transfer.items, hasLength(1));
      expect(transfer.status, equals(TransferStatus.pending));
    });

    test('should have null optional fields by default', () {
      final transfer = Transfer(
        id: 'transfer-1',
        sourceStoreId: 'store-1',
        destinationStoreId: 'store-2',
        items: const [],
        status: TransferStatus.pending,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(transfer.notes, isNull);
      expect(transfer.createdBy, isNull);
      expect(transfer.approvedBy, isNull);
      expect(transfer.rejectedBy, isNull);
      expect(transfer.rejectionReason, isNull);
      expect(transfer.receivedBy, isNull);
      expect(transfer.approvedAt, isNull);
      expect(transfer.shippedAt, isNull);
      expect(transfer.completedAt, isNull);
    });

    test('should store approval details when approved', () {
      final transfer = Transfer(
        id: 'transfer-1',
        sourceStoreId: 'store-1',
        destinationStoreId: 'store-2',
        items: const [],
        status: TransferStatus.approved,
        approvedBy: 'manager-1',
        approvedAt: DateTime(2026, 1, 16),
        createdAt: DateTime(2026, 1, 15),
      );

      expect(transfer.status, equals(TransferStatus.approved));
      expect(transfer.approvedBy, equals('manager-1'));
      expect(transfer.approvedAt, isNotNull);
    });

    test('should store rejection details when rejected', () {
      final transfer = Transfer(
        id: 'transfer-1',
        sourceStoreId: 'store-1',
        destinationStoreId: 'store-2',
        items: const [],
        status: TransferStatus.rejected,
        rejectedBy: 'manager-1',
        rejectionReason: 'Insufficient stock',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(transfer.status, equals(TransferStatus.rejected));
      expect(transfer.rejectedBy, equals('manager-1'));
      expect(transfer.rejectionReason, equals('Insufficient stock'));
    });
  });

  group('TransferItem Model', () {
    test('should construct with required fields', () {
      const item = TransferItem(
        productId: 'p1',
        productName: 'Product 1',
        quantity: 10,
      );

      expect(item.productId, equals('p1'));
      expect(item.productName, equals('Product 1'));
      expect(item.quantity, equals(10));
      expect(item.receivedQuantity, isNull);
    });

    test('should store received quantity', () {
      const item = TransferItem(
        productId: 'p1',
        productName: 'Product 1',
        quantity: 10,
        receivedQuantity: 8,
      );

      expect(item.receivedQuantity, equals(8));
    });
  });

  group('TransferStatus', () {
    test('should have all expected values', () {
      expect(TransferStatus.values, hasLength(6));
      expect(TransferStatus.values, contains(TransferStatus.pending));
      expect(TransferStatus.values, contains(TransferStatus.approved));
      expect(TransferStatus.values, contains(TransferStatus.rejected));
      expect(TransferStatus.values, contains(TransferStatus.shipped));
      expect(TransferStatus.values, contains(TransferStatus.completed));
      expect(TransferStatus.values, contains(TransferStatus.cancelled));
    });
  });

  group('TransferDirection', () {
    test('should have incoming and outgoing', () {
      expect(TransferDirection.values, hasLength(2));
      expect(TransferDirection.values, contains(TransferDirection.incoming));
      expect(TransferDirection.values, contains(TransferDirection.outgoing));
    });
  });
}
