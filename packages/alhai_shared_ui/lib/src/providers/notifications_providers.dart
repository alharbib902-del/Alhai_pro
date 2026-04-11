/// Notifications DB Providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

/// All notifications from DB
final dbNotificationsListProvider =
    FutureProvider.autoDispose<List<NotificationsTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.notificationsDao.getAllNotifications(storeId);
    });

/// Unread notifications from DB
final dbUnreadNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationsTableData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];
      final db = GetIt.I<AppDatabase>();
      return db.notificationsDao.getUnreadNotifications(storeId);
    });

/// Unread count from DB
final dbUnreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final unread = await ref.watch(dbUnreadNotificationsProvider.future);
  return unread.length;
});
