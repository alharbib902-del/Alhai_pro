import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  int _unreadCount = 3;
  final _controller = StreamController<AppNotification>.broadcast();

  @override
  Future<Paginated<AppNotification>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async => Paginated(items: [], total: 0, page: page, limit: limit);

  @override
  Future<void> markAsRead(String notificationId) async {
    _unreadCount--;
  }

  @override
  Future<void> markAllAsRead() async {
    _unreadCount = 0;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {}

  @override
  Future<int> getUnreadCount() async => _unreadCount;

  @override
  Stream<AppNotification> watchNotifications() => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

void main() {
  late NotificationService notificationService;
  late FakeNotificationsRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeNotificationsRepository();
    notificationService = NotificationService(fakeRepo);
  });

  tearDown(() {
    fakeRepo.dispose();
  });

  group('NotificationService', () {
    test('should be created', () {
      expect(notificationService, isNotNull);
    });

    test('getNotifications should return paginated', () async {
      final result = await notificationService.getNotifications();
      expect(result, isA<Paginated<AppNotification>>());
    });

    test('getUnreadCount should return count', () async {
      expect(await notificationService.getUnreadCount(), equals(3));
    });

    test('markAsRead should decrease count', () async {
      await notificationService.markAsRead('n1');
      expect(await notificationService.getUnreadCount(), equals(2));
    });

    test('markAllAsRead should set count to 0', () async {
      await notificationService.markAllAsRead();
      expect(await notificationService.getUnreadCount(), equals(0));
    });

    test('deleteNotification should not throw', () async {
      await notificationService.deleteNotification('n1');
    });

    test('watchNotifications should return stream', () {
      expect(
        notificationService.watchNotifications(),
        isA<Stream<AppNotification>>(),
      );
    });
  });
}
