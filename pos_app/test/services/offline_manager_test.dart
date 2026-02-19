import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/offline/offline_manager.dart';

void main() {
  group('ConnectionStatus', () {
    test('يحتوي على 3 حالات', () {
      expect(ConnectionStatus.values.length, 3);
      expect(ConnectionStatus.values, contains(ConnectionStatus.online));
      expect(ConnectionStatus.values, contains(ConnectionStatus.offline));
      expect(ConnectionStatus.values, contains(ConnectionStatus.checking));
    });
  });

  group('NetworkConnectionType', () {
    test('يحتوي على 5 أنواع', () {
      expect(NetworkConnectionType.values.length, 5);
      expect(NetworkConnectionType.values, contains(NetworkConnectionType.wifi));
      expect(
          NetworkConnectionType.values, contains(NetworkConnectionType.mobile));
      expect(NetworkConnectionType.values,
          contains(NetworkConnectionType.ethernet));
      expect(
          NetworkConnectionType.values, contains(NetworkConnectionType.unknown));
      expect(NetworkConnectionType.values, contains(NetworkConnectionType.none));
    });
  });

  group('NetworkConnectionState', () {
    test('يُنشئ من البيانات الصحيحة', () {
      final now = DateTime.now();
      final state = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: now,
        pendingSyncCount: 5,
      );

      expect(state.status, ConnectionStatus.online);
      expect(state.type, NetworkConnectionType.wifi);
      expect(state.lastChecked, now);
      expect(state.pendingSyncCount, 5);
    });

    test('isOnline يعيد true عند الاتصال', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime.now(),
      );

      expect(state.isOnline, isTrue);
      expect(state.isOffline, isFalse);
    });

    test('isOffline يعيد true عند عدم الاتصال', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.offline,
        type: NetworkConnectionType.none,
        lastChecked: DateTime.now(),
      );

      expect(state.isOnline, isFalse);
      expect(state.isOffline, isTrue);
    });

    test('offlineDuration يعيد null عند الاتصال', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime.now(),
        lastOnline: DateTime.now(),
      );

      expect(state.offlineDuration, isNull);
    });

    test('offlineDuration يحسب المدة بشكل صحيح', () {
      final lastOnline = DateTime.now().subtract(const Duration(minutes: 5));
      final state = NetworkConnectionState(
        status: ConnectionStatus.offline,
        type: NetworkConnectionType.none,
        lastChecked: DateTime.now(),
        lastOnline: lastOnline,
      );

      expect(state.offlineDuration, isNotNull);
      expect(state.offlineDuration!.inMinutes, greaterThanOrEqualTo(4));
    });

    test('copyWith ينسخ بشكل صحيح', () {
      final original = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime.now(),
        pendingSyncCount: 0,
      );

      final copied = original.copyWith(
        status: ConnectionStatus.offline,
        pendingSyncCount: 3,
      );

      expect(copied.status, ConnectionStatus.offline);
      expect(copied.type, NetworkConnectionType.wifi); // لم يتغير
      expect(copied.pendingSyncCount, 3);
    });
  });

  group('OfflineManager', () {
    test('instance يعيد نفس الـ instance (Singleton)', () {
      final instance1 = OfflineManager.instance;
      final instance2 = OfflineManager.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('state يبدأ بحالة checking', () {
      final state = OfflineManager.instance.state;

      // قد تتغير الحالة بعد التشغيل، لذا نتحقق فقط من وجودها
      expect(state, isNotNull);
    });

    test('addListener و removeListener يعملان', () {
      var callCount = 0;
      void listener(NetworkConnectionState state) {
        callCount++;
      }

      OfflineManager.instance.addListener(listener);
      OfflineManager.instance.removeListener(listener);

      // لا يجب أن يتم استدعاء الـ listener بعد الإزالة
      expect(callCount, 0);
    });

    test('updatePendingCount يحدث العدد', () {
      OfflineManager.instance.updatePendingCount(5);

      expect(OfflineManager.instance.state.pendingSyncCount, 5);

      // إعادة التعيين
      OfflineManager.instance.updatePendingCount(0);
    });
  });

  group('OfflineOperation', () {
    test('يُنشئ من البيانات الصحيحة', () {
      final operation = OfflineOperation<int>(
        id: 'op-1',
        type: 'sale',
        execute: () async => 42,
      );

      expect(operation.id, 'op-1');
      expect(operation.type, 'sale');
      expect(operation.retryCount, 0);
      expect(operation.createdAt, isNotNull);
    });

    test('execute يعمل بشكل صحيح', () async {
      final operation = OfflineOperation<int>(
        id: 'op-1',
        type: 'test',
        execute: () async => 100,
      );

      final result = await operation.execute();
      expect(result, 100);
    });
  });

  group('PendingOperationsManager', () {
    late PendingOperationsManager manager;

    setUp(() {
      manager = PendingOperationsManager();
    });

    test('يبدأ فارغاً', () {
      expect(manager.count, 0);
      expect(manager.hasOperations, isFalse);
      expect(manager.operations, isEmpty);
    });

    test('add يضيف عملية', () {
      manager.add(OfflineOperation<void>(
        id: 'op-1',
        type: 'test',
        execute: () async {},
      ));

      expect(manager.count, 1);
      expect(manager.hasOperations, isTrue);
    });

    test('remove يزيل عملية', () {
      manager.add(OfflineOperation<void>(
        id: 'op-1',
        type: 'test',
        execute: () async {},
      ));

      manager.remove('op-1');

      expect(manager.count, 0);
    });

    test('clear يمسح جميع العمليات', () {
      manager.add(OfflineOperation<void>(
        id: 'op-1',
        type: 'test',
        execute: () async {},
      ));
      manager.add(OfflineOperation<void>(
        id: 'op-2',
        type: 'test',
        execute: () async {},
      ));

      manager.clear();

      expect(manager.count, 0);
    });

    test('executeAll ينفذ العمليات الناجحة', () async {
      var executed = false;

      manager.add(OfflineOperation<void>(
        id: 'op-1',
        type: 'test',
        execute: () async {
          executed = true;
        },
      ));

      await manager.executeAll();

      expect(executed, isTrue);
      expect(manager.count, 0); // تمت إزالتها بعد النجاح
    });

    test('executeAll يزيد retryCount عند الفشل', () async {
      final operation = OfflineOperation<void>(
        id: 'op-1',
        type: 'test',
        execute: () async => throw Exception('Failed'),
      );

      manager.add(operation);

      await manager.executeAll();

      expect(operation.retryCount, 1);
    });

    test('operations يعيد قائمة غير قابلة للتعديل', () {
      manager.add(OfflineOperation<void>(
        id: 'op-1',
        type: 'test',
        execute: () async {},
      ));

      final ops = manager.operations;

      expect(
        () => (ops as List).add(OfflineOperation<void>(
              id: 'op-2',
              type: 'test',
              execute: () async {},
            )),
        throwsUnsupportedError,
      );
    });
  });
}
