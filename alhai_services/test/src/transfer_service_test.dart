import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeTransfersRepo implements TransfersRepository {
  Transfer? _lastCreated;

  @override
  Future<Transfer> getTransfer(String id) async =>
      _lastCreated ?? (throw UnimplementedError());
  @override
  Future<Paginated<Transfer>> getStoreTransfers(String storeId,
          {int page = 1,
          int limit = 20,
          TransferStatus? status,
          TransferDirection? direction}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Transfer> createTransfer(
      {required String sourceStoreId,
      required String destinationStoreId,
      required List<TransferItem> items,
      String? notes}) async {
    _lastCreated = Transfer(
        id: 't-1',
        sourceStoreId: sourceStoreId,
        destinationStoreId: destinationStoreId,
        items: items,
        status: TransferStatus.pending,
        notes: notes,
        createdAt: DateTime.now());
    return _lastCreated!;
  }

  @override
  Future<Transfer> approveTransfer(String id, String approvedBy) async =>
      Transfer(
          id: id,
          sourceStoreId: 's1',
          destinationStoreId: 's2',
          items: [],
          status: TransferStatus.approved,
          createdAt: DateTime.now());
  @override
  Future<Transfer> rejectTransfer(
          String id, String rejectedBy, String reason) async =>
      Transfer(
          id: id,
          sourceStoreId: 's1',
          destinationStoreId: 's2',
          items: [],
          status: TransferStatus.rejected,
          createdAt: DateTime.now());
  @override
  Future<Transfer> shipTransfer(String id) async => Transfer(
      id: id,
      sourceStoreId: 's1',
      destinationStoreId: 's2',
      items: [],
      status: TransferStatus.shipped,
      createdAt: DateTime.now());
  @override
  Future<Transfer> completeTransfer(String id, String receivedBy) async =>
      Transfer(
          id: id,
          sourceStoreId: 's1',
          destinationStoreId: 's2',
          items: [],
          status: TransferStatus.completed,
          createdAt: DateTime.now());
  @override
  Future<Transfer> cancelTransfer(String id, String reason) async => Transfer(
      id: id,
      sourceStoreId: 's1',
      destinationStoreId: 's2',
      items: [],
      status: TransferStatus.cancelled,
      createdAt: DateTime.now());
}

void main() {
  late TransferService transferService;
  setUp(() {
    transferService = TransferService(FakeTransfersRepo());
  });

  group('TransferService', () {
    test('should be created', () {
      expect(transferService, isNotNull);
    });

    test('createTransfer should create pending transfer', () async {
      final t = await transferService.createTransfer(
        sourceStoreId: 'store-1',
        destinationStoreId: 'store-2',
        items: [
          TransferItem(productId: 'p1', productName: 'Coffee', quantity: 50)
        ],
      );
      expect(t.status, equals(TransferStatus.pending));
    });

    test('getStoreTransfers should return paginated', () async {
      final result = await transferService.getStoreTransfers('store-1');
      expect(result, isA<Paginated<Transfer>>());
    });

    test('approveTransfer should return approved', () async {
      final t = await transferService.approveTransfer('t-1', 'mgr-1');
      expect(t.status, equals(TransferStatus.approved));
    });

    test('rejectTransfer should return rejected', () async {
      final t =
          await transferService.rejectTransfer('t-1', 'mgr-1', 'Not needed');
      expect(t.status, equals(TransferStatus.rejected));
    });

    test('shipTransfer should return shipped', () async {
      final t = await transferService.shipTransfer('t-1');
      expect(t.status, equals(TransferStatus.shipped));
    });

    test('completeTransfer should return completed', () async {
      final t = await transferService.completeTransfer('t-1', 'receiver-1');
      expect(t.status, equals(TransferStatus.completed));
    });

    test('cancelTransfer should return cancelled', () async {
      final t = await transferService.cancelTransfer('t-1', 'Changed plans');
      expect(t.status, equals(TransferStatus.cancelled));
    });
  });
}
